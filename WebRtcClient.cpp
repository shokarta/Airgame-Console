#include "WebRtcClient.h"

#include <QDebug>
#include <QJsonObject>

#include <api/jsep.h>

#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/audio_codecs/builtin_audio_decoder_factory.h"

#include "api/video_codecs/builtin_video_encoder_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"


using namespace webrtc;

// ============================
// OBSERVERS (FIXED API)
// ============================

class SetSessionDescriptionObserverImpl
    : public webrtc::SetSessionDescriptionObserver
{
public:
    static webrtc::scoped_refptr<SetSessionDescriptionObserverImpl> Create()
    {
        return webrtc::scoped_refptr<SetSessionDescriptionObserverImpl>(
            new webrtc::RefCountedObject<SetSessionDescriptionObserverImpl>()
        );
    }

    void OnSuccess() override {}
    void OnFailure(webrtc::RTCError error) override
    {
        qDebug() << "SetDescription failed";
    }
};

class CreateOfferObserver : public webrtc::CreateSessionDescriptionObserver
{
public:
    webrtc::scoped_refptr<webrtc::PeerConnectionInterface> peer;
    WebRtcClient* client;

    CreateOfferObserver(webrtc::scoped_refptr<webrtc::PeerConnectionInterface> p, WebRtcClient* c)
        : peer(p), client(c) {}

    void OnSuccess(webrtc::SessionDescriptionInterface* desc) override
    {
        peer->SetLocalDescription(
            SetSessionDescriptionObserverImpl::Create().get(),  // ✅ FIX API
            desc
        );

        std::string sdp;
        desc->ToString(&sdp);

        emit client->offerCreated(QString::fromStdString(sdp));
    }

    void OnFailure(webrtc::RTCError error) override
    {
        qDebug() << "Offer failed";
    }
};

// ============================
// CONSTRUCTOR / INIT
// ============================

WebRtcClient::WebRtcClient(QObject *parent)
    : QObject(parent)
{
}

WebRtcClient::~WebRtcClient()
{
}

bool WebRtcClient::initialize()
{
    m_networkThread = webrtc::Thread::Create();
    m_workerThread = webrtc::Thread::Create();
    m_signalingThread = webrtc::Thread::Create();

    m_networkThread->Start();
    m_workerThread->Start();
    m_signalingThread->Start();

    m_factory = webrtc::CreatePeerConnectionFactory(
        m_networkThread.get(),
        m_workerThread.get(),
        m_signalingThread.get(),
        nullptr, // AudioDeviceModule

        webrtc::CreateBuiltinAudioEncoderFactory(),
        webrtc::CreateBuiltinAudioDecoderFactory(),

        webrtc::CreateBuiltinVideoEncoderFactory(),
        webrtc::CreateBuiltinVideoDecoderFactory(),

        nullptr, // AudioMixer
        nullptr  // AudioProcessing
    );

    if (!m_factory) {
        qDebug() << "Factory failed";
        return false;
    }

    return createPeerConnection();
}


// ============================
// PEER CONNECTION
// ============================

bool WebRtcClient::createPeerConnection()
{
    webrtc::PeerConnectionInterface::RTCConfiguration config;

    webrtc::PeerConnectionDependencies deps(this);

    auto result = m_factory->CreatePeerConnectionOrError(config, std::move(deps));

    if (!result.ok()) {
        qDebug() << "PeerConnection failed";
        return false;
    }

    m_peer = result.value();

    return true;
}


// ============================
// OFFER / ANSWER
// ============================

void WebRtcClient::createOffer()
{
    m_peer->CreateOffer(
        new webrtc::RefCountedObject<CreateOfferObserver>(m_peer, this),
        webrtc::PeerConnectionInterface::RTCOfferAnswerOptions()
    );
}

void WebRtcClient::setRemoteAnswer(QString sdp)
{
    webrtc::SdpParseError error;

    std::unique_ptr<webrtc::SessionDescriptionInterface> desc =
        webrtc::CreateSessionDescription(
            webrtc::SdpType::kAnswer,
            sdp.toStdString(),
            &error
        );

    if (!desc) {
        qDebug() << "Parse answer failed";
        return;
    }

    m_peer->SetRemoteDescription(
        SetSessionDescriptionObserverImpl::Create().get(),   // ✅ FIX API
        desc.release()
    );
}

// ============================
// ICE
// ============================

void WebRtcClient::addIceCandidate(QString candidate, QString mid, int mlineIndex)
{
    webrtc::SdpParseError error;

    webrtc::IceCandidateInterface* ice =
        webrtc::CreateIceCandidate(
            mid.toStdString(),
            mlineIndex,
            candidate.toStdString(),
            nullptr
        );

    if (ice) {
        m_peer->AddIceCandidate(ice);
    }

}

void WebRtcClient::OnIceCandidate(const webrtc::IceCandidateInterface* candidate)
{
    std::string s;
    candidate->ToString(&s);

    QJsonObject obj;
    obj["candidate"] = QString::fromStdString(s);
    obj["sdpMid"] = QString::fromStdString(candidate->sdp_mid());
    obj["sdpMLineIndex"] = candidate->sdp_mline_index();

    m_localCandidates.append(obj);
    emit localIceCandidatesChanged();
}

// ============================

QJsonArray WebRtcClient::localIceCandidates() const
{
    return m_localCandidates;
}

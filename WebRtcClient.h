#pragma once

#include <QObject>
#include <QJsonArray>

#include <api/peer_connection_interface.h>
#include <api/create_peerconnection_factory.h>

#include <rtc_base/thread.h>

class WebRtcClient : public QObject, public webrtc::PeerConnectionObserver
{
    Q_OBJECT

    Q_PROPERTY(QJsonArray localIceCandidates READ localIceCandidates NOTIFY localIceCandidatesChanged)

public:
    explicit WebRtcClient(QObject *parent = nullptr);
    ~WebRtcClient();

    Q_INVOKABLE bool initialize();
    Q_INVOKABLE void createOffer();

    Q_INVOKABLE void setRemoteAnswer(QString sdp);
    Q_INVOKABLE void addIceCandidate(QString candidate, QString mid, int mlineIndex);

    QJsonArray localIceCandidates() const;

signals:
    void offerCreated(QString sdp);
    void localIceCandidatesChanged();

private:
    webrtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> m_factory;
    webrtc::scoped_refptr<webrtc::PeerConnectionInterface> m_peer;

    std::unique_ptr<webrtc::Thread> m_networkThread;
    std::unique_ptr<webrtc::Thread> m_workerThread;
    std::unique_ptr<webrtc::Thread> m_signalingThread;

    QJsonArray m_localCandidates;

    bool createPeerConnection();

    // PeerConnectionObserver
    void OnIceCandidate(const webrtc::IceCandidateInterface* candidate) override;
};
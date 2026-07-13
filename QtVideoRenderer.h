#pragma once

#include <QObject>
#include <functional>

#include <rtc_video_renderer.h>
#include <rtc_video_frame.h>

class QtVideoRenderer : public QObject, public libwebrtc::RTCVideoRenderer<libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame>>
{
    //Q_OBJECT

    public:
        explicit QtVideoRenderer(QObject *parent = nullptr);

        std::function<void(libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame>)> onFrame;

        void OnFrame(libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> frame) override;
};

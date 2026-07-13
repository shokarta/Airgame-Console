#pragma once

#include <QQuickFramebufferObject>
#include <QMutex>
#include <rtc_video_frame.h>

class MyFboRenderer;

class MyFboItem : public QQuickFramebufferObject
{
    Q_OBJECT

    public:
        MyFboItem();

        Renderer *createRenderer() const override;

        // 👉 přijme frame z WebRTC
        void setFrame(const libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> &frame);

        // 👉 renderer si to vyzvedne
        libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> getFrame();

    private:
        mutable QMutex m_mutex;
        libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> m_frame;
};
#include "QtVideoRenderer.h"
#include <QDebug>

QtVideoRenderer::QtVideoRenderer(QObject *parent) : QObject(parent)
{
}

void QtVideoRenderer::OnFrame(libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> frame)
{
    printf("🔥 FRAME ARRIVED\n"); fflush(stdout);


    if (!onFrame) {
            qDebug() << "❌ onFrame not connected!";
        }


    if (onFrame)
        onFrame(frame);
}

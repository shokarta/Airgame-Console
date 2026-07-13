#include "MyFboItem.h"
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>

// ============================
// Renderer
// ============================

class MyFboRenderer : public QQuickFramebufferObject::Renderer, protected QOpenGLFunctions
{
	public:
		MyFboRenderer(MyFboItem* item) : m_item(item)
		{
			initializeOpenGLFunctions();
		}

		void render() override
		{
			//qDebug() << "RENDER CALLED";

			auto frame = m_item->getFrame();

			glViewport(0, 0, m_width, m_height);

			glDisable(GL_DEPTH_TEST);

			// clear
			//glClearColor(0, 0, 0, 1);
			if (frame) {
				qDebug() << "✅ RENDER HAS FRAME";
				glClearColor(0,1,0,1); // GREEN
			}
			else {
				glClearColor(1,0,0,1); // RED
			}

			glClear(GL_COLOR_BUFFER_BIT);

			// 👉 vezmi frame
			// auto frame = m_item->getFrame();

			// if (frame) {
			// 	// 🔥 HERE bude NV12 upload + shader (zatím debug)
			// 	glClearColor(0.0f, 0.8f, 0.2f, 1.0f);
			// 	glClear(GL_COLOR_BUFFER_BIT);
			// }

			update();
		}

		QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override
		{
			qDebug() << "FBO SIZE:" << size;

			m_width = size.width();
			m_height = size.height();

			QOpenGLFramebufferObjectFormat format;
			format.setAttachment(QOpenGLFramebufferObject::Depth);

			return new QOpenGLFramebufferObject(size, format);
		}

	private:
		MyFboItem* m_item;
		int m_width = 0;
		int m_height = 0;
};

// ============================
// MyFboItem
// ============================

MyFboItem::MyFboItem()
{
	setMirrorVertically(true);		// optional
}

QQuickFramebufferObject::Renderer *MyFboItem::createRenderer() const
{
	return new MyFboRenderer(const_cast<MyFboItem*>(this));
}

void MyFboItem::setFrame(const libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> &frame)
{
	QMutexLocker lock(&m_mutex);
	m_frame = frame;
	update(); // trigger render
}

libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> MyFboItem::getFrame()
{
	QMutexLocker lock(&m_mutex);
	return m_frame;
}
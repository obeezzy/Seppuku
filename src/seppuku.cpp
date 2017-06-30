#include "seppuku.h"
#include <QScreen>
#include <QDebug>
#include <QtGui/QGuiApplication>
#include <QDir>
#include <QUrl>
#include <QtQml>
#include <QUrl>

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras>
#endif

Seppuku::Seppuku(QObject *parent) :
    mobile(false),
    dpConstant(1.0),
    scaleFactor(1.0),
    QObject(parent)
{
    init();
}

Seppuku::~Seppuku()
{

}

void Seppuku::init() {
    QScreen *screen = qApp->primaryScreen();
    qreal dpi = screen->physicalDotsPerInch() * screen->devicePixelRatio();
    qDebug() << "Physical dpi = " << screen->physicalDotsPerInch();
    qDebug() << "Device pixel ratio = " << screen->devicePixelRatio();
    mobile = false;

#if defined(Q_OS_IOS)
    // iOS integration of scaling (retina, non-retina, 4K) does itself.
    dpi = screen->physicalDotsPerInch();
    mobile = true;
#elif defined(Q_OS_ANDROID)
    // https://bugreports.qt-project.org/browse/QTBUG-35701
    // recalculate dpi for Android

    QAndroidJniEnvironment env;
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject resources = activity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();

        return;// EXIT_FAILURE;
    }

    QAndroidJniObject displayMetrics = resources.callObjectMethod("getDisplayMetrics", "()Landroid/util/DisplayMetrics;");
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();

        return;// EXIT_FAILURE;
    }
    dpi = displayMetrics.getField<int>("densityDpi");
    mobile = true;
#else
    // standard dpi
    dpi = screen->logicalDotsPerInch() * screen->devicePixelRatio();
#endif

    // now calculate the dp ratio
    dpConstant = dpi / 160.f;

    qDebug() << "DP multiplier of platform: " << dpConstant;
}

QUrl Seppuku::resolvedUrl(const QString &url)
{
    if(url.isEmpty())
        return QUrl();

    return QUrl(url);
}

void Seppuku::saveState()
{

}



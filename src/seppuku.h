#ifndef SEPPUKU_H
#define SEPPUKU_H

#include <QObject>
#include <QUrl>

class QQmlEngine;
class QJSEngine;

class Seppuku : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isMobile READ isMobile NOTIFY isMobileChanged)
public:
    explicit Seppuku(QObject *parent = 0);
    ~Seppuku();

    bool isMobile() { return mobile; }
    Q_INVOKABLE qreal dp(qreal pixels) { return dpConstant * pixels; }
    Q_INVOKABLE qreal sp(qreal pixels) { return dpConstant * pixels * scaleFactor; }
    Q_INVOKABLE QUrl resolvedUrl(const QString &);
    Q_INVOKABLE void saveState();
signals:
    void isMobileChanged();
public slots:
private:
    bool mobile;
    qreal dpConstant;
    qreal scaleFactor;

    void init();
};

// Second, define the singleton type provider function (callback).
static QObject *seppuku_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    Seppuku *seppuku = new Seppuku();
    return seppuku;
}

#endif // SEPPUKU_H

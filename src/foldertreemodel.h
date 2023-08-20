#ifndef FOLDERTREEMODEL_H
#define FOLDERTREEMODEL_H

#include <QFileSystemModel>
#include <QQmlEngine>

class FolderTreeModel : public QFileSystemModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit FolderTreeModel(QObject *parent = nullptr);
};

#endif // FOLDERTREEMODEL_H

#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>
#include <QQmlListProperty>
#include <QtQmlIntegration>

#include "treenode.h"

class TreeModel : public QAbstractItemModel {
    Q_OBJECT
    QML_NAMED_ELEMENT(KmcTreeModel)

    Q_PROPERTY(QQmlListProperty<TreeNode> topItems READ topItems FINAL)
    Q_CLASSINFO("DefaultProperty", "topItems")
public:
    explicit TreeModel(QObject* parent = nullptr) : QAbstractItemModel(parent) {}

public:
    int rowCount(const QModelIndex& index) const override;
    int columnCount(const QModelIndex& index) const override;

    QModelIndex index(int row, int column, const QModelIndex& parent) const override;
    QModelIndex parent(const QModelIndex& childIndex) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::DisplayRole) override;

public:
    const QVector<TreeNode*>& rootItems() const { return rootItem_.childNodes_; }

    Q_INVOKABLE void addTopLevelItem(TreeNode* child);

    Q_INVOKABLE void addItem(TreeNode* parent, TreeNode* child);

    Q_INVOKABLE void removeItem(TreeNode* item);

    Q_INVOKABLE TreeNode* rootItem() const;

    Q_INVOKABLE void clear();

    // This is for Qml, if you are using c++, please try rootItems()
    QQmlListProperty<TreeNode> topItems();

private:
    TreeNode* internalPointer(const QModelIndex& index) const;
    TreeNode  rootItem_;
};

#endif  // QML_TREEVIEW_TREE_MODEL_H

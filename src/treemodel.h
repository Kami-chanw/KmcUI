#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>

#include "qqmlintegration.h"
#include "qqmllist.h"
#include "treenode.h"

class TreeModel : public QAbstractItemModel {
    Q_OBJECT
    QML_NAMED_ELEMENT(KmcTreeModel)

    Q_PROPERTY(QQmlListProperty<TreeNode> topItems READ topItems FINAL)
    Q_CLASSINFO("DefaultProperty", "topItems")
public:
    explicit TreeModel(QObject* parent = nullptr);
    ~TreeModel() {}
public:
    int rowCount(const QModelIndex& index) const override;
    int columnCount(const QModelIndex& index) const override;

    QModelIndex index(int row, int column, const QModelIndex& parent) const override;
    QModelIndex parent(const QModelIndex& childIndex) const override;

    QVariant data(const QModelIndex& index, int role = 0) const override;
    bool     setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;

public:
    //! Add an item to the top level.
    void addTopLevelItem(TreeNode* child);

    //! Add the item child to the parent node.
    void addItem(TreeNode* parent, TreeNode* child);

    //! Remove the item and all its childNodes.
    void removeItem(TreeNode* item);

    //! Return the root item.
    TreeNode* rootItem() const;

    //! Remove all the elements from the tree.
    Q_INVOKABLE void clear();

    QQmlListProperty<TreeNode> topItems();

signals:


private:
    TreeNode* internalPointer(const QModelIndex& index) const;

    TreeNode rootItem_;
};


#endif  // QML_TREEVIEW_TREE_MODEL_H

#ifndef TREENODE_H
#define TREENODE_H

#include <QQmlListProperty>
#include <QVariant>
#include <QtQmlIntegration>

/*!
 * This class represents a node of the TreeModel.
 * TreeItem can be used to set and retreive information about the node,
 * insertion and removal is meant to be deal by the model.
 */
class TreeNode : public QObject {
    friend class TreeModel;
    Q_OBJECT
    QML_NAMED_ELEMENT(KmcTreeNode)
    Q_PROPERTY(QQmlListProperty<TreeNode> childNodes READ childNodes FINAL)
    Q_PROPERTY(QVariant data READ data WRITE setData NOTIFY dataChanged FINAL)
    Q_CLASSINFO("DefaultProperty", "childNodes")
public:
    QQmlListProperty<TreeNode> childNodes();

    //! Instance a tree item with empty data.
    explicit TreeNode(TreeNode* parent = nullptr);

    //! Instance a tree with the input data.
    explicit TreeNode(const QVariant& data, TreeNode* parent = nullptr);

    //! Destroy the item and all its children.
    ~TreeNode();

    //! Return the internal data.
    const QVariant& data() const;

    //! Set the internal data.
    void setData(const QVariant& data);

    //! Return the number of children of the item.
    qsizetype childCount() const;

    //! Return the number of the row referred to the parent item.
    int row() const;

    //! Return true if the item has no children.
    bool isLeaf() const;

    //! Return the depth of the item in the hierarchy.
    int depth() const;

    void clear();

signals:
    void dataChanged(const QVariant&);

private:
    void appendChild(TreeNode* item);
    void removeChild(TreeNode* item);

    TreeNode* parentItem() const;
    TreeNode* child(qsizetype row);

    static void      appendChild(QQmlListProperty<TreeNode>*, TreeNode*);
    static qsizetype childCount(QQmlListProperty<TreeNode>*);
    static TreeNode* child(QQmlListProperty<TreeNode>*, qsizetype);
    static void      clear(QQmlListProperty<TreeNode>*);

private:
    QVariant           itemData_;
    QVector<TreeNode*> childNodes_;  // technologically, we can use QObject::children, but we cannot
                                     // ensure the order correction of its children.
};

#endif  // TREENODE_H

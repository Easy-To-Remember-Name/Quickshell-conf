#include <QApplication>
#include <QWidget>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVBoxLayout>
#include <QTreeWidget>
#include <QTreeWidgetItem>
#include <QColorDialog>
#include <QHeaderView>
#include <QDebug>

QString themeFilePath = "Theme.json";

class ThemeEditor : public QWidget {
    Q_OBJECT

public:
    ThemeEditor(QWidget *parent = nullptr) : QWidget(parent) {
        setWindowTitle("Theme.json Editor");
        QVBoxLayout *mainLayout = new QVBoxLayout(this);

        treeWidget = new QTreeWidget();
        treeWidget->setHeaderLabels({ "Key", "Value" });
        treeWidget->setColumnCount(2);
        treeWidget->setAlternatingRowColors(true);
        treeWidget->setUniformRowHeights(true);
        treeWidget->setExpandsOnDoubleClick(true);

        treeWidget->header()->setStretchLastSection(false);
        treeWidget->header()->setSectionResizeMode(0, QHeaderView::Interactive);
        treeWidget->header()->setSectionResizeMode(1, QHeaderView::Fixed);
        treeWidget->header()->setMinimumSectionSize(300);
        treeWidget->setColumnWidth(0, 300);
        treeWidget->setColumnWidth(1, 100);

        mainLayout->addWidget(treeWidget);
        loadTheme();
    }

private:
    QTreeWidget *treeWidget;
    QJsonObject original;

    void loadTheme() {
        QFile file(themeFilePath);
        if (!file.open(QIODevice::ReadOnly)) {
            qWarning("Could not open Theme.json");
            return;
        }

        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        file.close();
        original = doc.object();

        treeWidget->clear();
        buildTree(nullptr, original);
    }

    void buildTree(QTreeWidgetItem *parent, const QJsonObject &obj) {
        for (const QString& key : obj.keys()) {
            QJsonValue val = obj[key];

            QTreeWidgetItem *item = parent ? new QTreeWidgetItem(parent) : new QTreeWidgetItem(treeWidget);
            item->setText(0, key);
            item->setToolTip(0, key);

            if (val.isObject()) {
                buildTree(item, val.toObject());
            } else if (val.isString()) {
                QString colorStr = val.toString();
                item->setText(1, colorStr);
                item->setBackground(1, QColor(colorStr));
                item->setTextAlignment(1, Qt::AlignCenter);
                item->setToolTip(1, colorStr);


                connect(treeWidget, &QTreeWidget::itemClicked, this, [=](QTreeWidgetItem *clicked, int column) {
                    if (clicked == item && column == 1) {
                        QColor newColor = QColorDialog::getColor(
                            QColor(colorStr),
                            this,
                            key,
                            QColorDialog::DontUseNativeDialog
                        );
                        if (newColor.isValid()) {
                            QString hex = newColor.name();
                            item->setText(1, hex);
                            item->setBackground(1, newColor);
                            item->setToolTip(1, hex);
                            updateJsonFromTree();
                            saveTheme();
                        }
                    }
                });
            }
        }
    }

    void updateJsonFromTree() {
        original = buildJsonFromTree(nullptr);
    }

    QJsonObject buildJsonFromTree(QTreeWidgetItem *parent) {
        QJsonObject result;
        int childCount = parent ? parent->childCount() : treeWidget->topLevelItemCount();

        for (int i = 0; i < childCount; ++i) {
            QTreeWidgetItem *item = parent ? parent->child(i) : treeWidget->topLevelItem(i);
            QString key = item->text(0);

            if (item->childCount() > 0) {
                result[key] = buildJsonFromTree(item);
            } else {
                result[key] = item->text(1);
            }
        }

        return result;
    }

    void saveTheme() {
        QFile file(themeFilePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qWarning("Could not save Theme.json");
            return;
        }

        QJsonDocument doc(original);
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
    }
};

#include "main.moc"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    ThemeEditor editor;
    editor.resize(700, 500); 
    editor.show();
    return app.exec();
}

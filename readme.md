# Note cutter

## Зачем это?

Если вы так же как и я учите мелодии с помощью Anki, то приходится разрезать
ноты на части в графическом редакторе. Эта программа позволяет упростить
разрезание на мелкие заучиваемые кусочки.

## Как установить?

Для работы требуется Processing. Достаточно установить его с сайта и запустить
данный скрипт.

## Как это работает?

Находим этот блок в программе и прописываем путь до файла, размер изображения и
названия исходящих файлов.

```Processing
void settings() {
  imageFilename = "johny.jpg";
  imageWidth = 783;
  imageHeight = 449;
  deckName = "johny";
  
```

После этого находим на картинке блок с ключом и выписываем координаты в программу.

```Processing
 Rectangle keyRectangle = new Rectangle(30,6,51,75);
  
```

А затем прописываем остальные блоки которые будут вставлены в массив
tabRectangle

```Processing
  tabRectangle.add(new Rectangle(81, 6, 31, 75));
  tabRectangle.add(new Rectangle(102, 6, 197, 75));
  tabRectangle.add(new Rectangle(102 + 197, 6, 164, 75));
```

## Пример работы

![Программа](\screenshot\work_screen.png)


![Результат](\screenshot\johny1.jpg)

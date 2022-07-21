# floodpipe
## Pascal programming internship 2022
Implementiert werden soll das Spiel FloodPipe, in dem der Spieler ein Spielfeld präsentiert bekommt, auf dem unterschiedliche Rohrstücke platziert sind. Der Spieler kann durch (mehrfaches) Anklicken einer Zelle das jeweilige Rohrstück drehen, um Verbindungen herzustellen. Ziel ist es, alle Rohre derart zu verbinden, dass jedes Rohrstück von der Quelle ausgehend geflutet wird und keine offenen Enden vorhanden sind.

![shuffeled](https://user-images.githubusercontent.com/62332469/180308016-e7b529f5-f18c-430a-93f5-88da8abf2c85.jpg) ![solved](https://user-images.githubusercontent.com/62332469/180308043-be8cca45-0de2-423b-a478-a6c337bc33f3.jpg)

## Belegung des Spielfeldes

Jede Zelle des Spielfeldes enthält genau ein Rohrstück oder ein Mauerstück (grau). Als Rohrstücke existieren Geraden, Kurven, T-Verzweigungen und Endstücke. Außerdem können per Default maximal 10% der Zellen mit Mauerstücken belegt sein (s.a. Einstellungen). Die Rohre müssen als solche erkennbar sein und die Übergänge zueinander passen. Erlaubt sind einfache dickere Linien oder auch andere Formen auf dem Canvas (wie z.B. Rechtecke oder Bögen), aber auch ansprechendere bzw. komplexere Darstellungen wie z.B. die rechts zu sehende mit "Verbindungsstücken" (auf Basis von selbst erstellten Bildern).

Bei jedem Spielstart wird durch das Programm ein gelöstes Spielfeld erstellt (aber so noch nicht dargestellt). Dafür werden Geraden, Kurven und T-Verzweigungen zunächst mit gleicher Wahrscheinlichkeit eingesetzt. Das bedeutet nicht, dass im fertiggestellten Spielfeld die Rohrstücke in jeweils gleicher Anzahl vertreten sind (auch wenn alle Teile bei der Erstellung gleich wahrscheinlich sind, kann es ja z.B mehr Gerade als Kurven geben!). Endstücke werden nur verwendet, wenn an dieser Stelle kein anderes Element passt. Sind weniger Zellen als oder gleich viele Zellen wie Mauerstücke erlaubt frei geblieben, so können diese in den freien Zellen platziert werden. Anschließend wird das Feld gemixt, also jedes Element durch eine jeweils zufällige Anzahl von Drehungen rotiert, so dass die zu lösende Situation entsteht. Erst diese Situation wird angezeigt.

Die Quelle liegt an einer zufälligen Position auf dem Spielfeld. Sie kann auf jedem der Rohrstücke platziert sein (aber nicht auf Mauern). Die Quelle darf beliebig symbolisiert werden, muss aber einfarbig sein und das unterliegende Rohrstück erkennbar lassen. In den Beispielbildern dieser Aufgabenstellung wird sie durch das rechtsstehende Bild symbolisiert.

Das Spielfeld darf (abweichend von den allgemeinen Regularien) als dynamisches Array implementiert werden.

## Einstellungen

### Der Spieler soll über ein Optionsmenü ändern können:

die Anzahl der Spalten und der Reihen, so dass (auch nicht quadratische) Feldgrößen von 2*2 bis 15*15 entstehen können,
den maximalen Anteil eingesetzter Mauerstücke in Prozent,
die Animationsgeschwindigkeit,
den Überlaufmodus (ja/nein).
Bei eingeschaltetem Überlaufmodus besteht eine direkte Verbindung zwischen oberem und unterem bzw. zwischen linkem und rechtem Rand, so dass z.B. die nebenstehende Konstellation möglich ist:

Während eine Änderung der Animationsgeschwindigkeit sofort im laufenden Spiel umgesetzt wird, erfordert eine Änderung der Feldgröße oder des Überlaufmodus einen Neustart des Spiels. Ist der Spieler mit dem Neustart nicht einverstanden, wird weder die Feldgröße noch der Überlaufmodus verstellt.

Eine Änderung der Spalten- oder Zeilenanzahl verändert nicht die Spielfeldgröße, sondern die Zellengröße. Die Spielfeldgröße ändert sich ausschließlich mit dem Variieren der Formulargröße (wird das Formular also z.B. größer gezogen, soll sich auch das Spielfeld dem anpassen), wobei sich die Zellgrößen natürlich auch wieder anpassen müssen.

## Bedienung des Spiels

Ein Klick auf ein Rohrstück mit der linken Maustaste bewirkt ein Linksdrehen des Rohrstückes um 90°, ein Rechtsklick dreht das Rohrstück im Uhrzeigersinn um 90°. Nach jeder Drehung soll sichtbar werden, welche Rohrstücke jetzt von der Quelle aus gefüllt werden und welche abgeschnitten sind. Die Drehung soll nicht animiert werden, sondern "schlagartig" erfolgen.

Die Füllung der Rohre soll hingegen animiert erfolgen. Dafür soll von der Quelle ausgehend je ein füllbares Rohrstück komplett (also nicht "pixelweise") die Farbe ändern, bis keine weiteren Rohrstücke gefüllt werden können. Bereits vorab gefüllte Rohrstücke sollen allerdings nicht zur Verzögerung der Anzeige führen (sie werden also quasi nicht noch einmal gefüllt, sondern die Animation beginnt direkt am ersten bisher noch leeren Rohrstück). Die Geschwindigkeit der Animation soll für den Benutzer in einem sinnvollen Rahmen über das Optionsmenü änderbar sein.

### Beispiel: Drehen des Rohres an C4
firstMini.png ⇒ secMini.png

Dreht man das Rohr an Position C4 um 90° nach rechts (im Uhrzeigersinn), so sollen nacheinander (also mit geringem zeitlichen Abstand) erst C3, dann C2, dann C1 und gleichzeitig B2, dann C0 und gleichzeitig B1 gefüllt werden. Hier ist ein Algorithmus erforderlich, der jeweils alle Rohrstücke bestimmt, die selbst noch leer, aber direkt mit bereits gefüllten Rohren verbunden sind und dies über mehrere Schritte, bis keine weiteren verbundenen Stücke mehr vorhanden sind (-> Rekursion).

Wird C4 wieder zurückgedreht, dürfen alle nicht mehr gefüllten Rohrstücke auf einmal geleert werden. Eine Animation für das Leeren ist also nicht erforderlich (aber erlaubt).

Sind alle Rohrstücke an ihren offenen Seiten verbunden, so wird dem Spieler ausgegeben, wie viele Klicks er zum Lösen des Rätsels benötigt hat. Anschließend wird ein neues Spiel gestartet.

## Editor

Der Nutzer kann auch selbst ein Spielfeld erstellen. Dafür wird über einen Menüpunkt in einen Editormodus geschaltet oder auch in den Spielmodus zurückgeschaltet. Die aktuelle Spielfeldbelegung wird beim Wechsel in den Editormodus übernommen. Es ist jedoch auch jederzeit möglich, ein neues Spielfeld zu erstellen. In einem neuen Spielfeld ist initial jede Zelle mit einem Mauerstück belegt.

Der Überlaufmodus kann jederzeit an-/ausgeschaltet werden. Die Anzahl der Zeilen und Spalten ist während der Erstellung jederzeit veränderbar (mit den gleichen Grenzen wie bei den Einstellungen). Wird eine Reihenanzahl verändert, so bleibt die Zellenbelegung der dann noch vorhandenen Zellen bestehen, neue Reihen werden mit Mauerstücken gefüllt (es können im Editor generell durchaus mehr als 10% Mauerstücke vom Nutzer gesetzt werden).

Im Editormodus werden neben dem Spielfeld die einsetzbaren Rohrstücke, ein Mauerstück und eine Quelle angezeigt. Diese Elemente können dann auf dem Feld platziert werden. Eine schon vorhandene Belegung einer Zelle wird dabei einfach überschrieben.
Wie im Spielmodus kann mit Klick auf eine belegte Zelle das enthaltene Rohrstück gedreht werden. Eine Quelle kann nur auf ein durch ein Rohrstück belegtes Feld gesetzt werden. Ist schon eine Quelle an anderer Stelle auf dem Feld, wird diese gleichzeitig entfernt (es darf nur eine Quelle geben). Wird ein Mauerstück auf eine Zelle mit Quelle gesetzt, wird die Quelle entfernt. Ein Feld ohne Quelle darf allerdings nicht gespeichert werden können und von dort soll auch kein Wechsel in den Spielmodus möglich sein.
Sobald eine Quelle platziert ist, füllen sich die gefüllten Rohre wie im Spielmodus, damit ein gelöstes Feld besser erkennbar ist. Hier soll allerdings keine zeitraubende Animation eingesetzt werden bzw. die Animation sehr schnell und dadurch unmerkbar für den Nutzer erfolgen.

Ist das Feld gelöst, wird dies angezeigt.
Das Feld kann jederzeit gemixt, also jede Zelle um eine zufällige Anzahl von Drehungen rotiert werden.

## Speichern von Daten

Wie jedes mit Dateien arbeitende Programm hat dieses Programm ein Menü mit den Punkten Neu, Laden, Speichern und Beenden. Das aktuelle Spiel (Spielfeldgröße und -belegung) kann jederzeit in einer Datei gespeichert werden.

Diese Daten können zu einem späteren Zeitpunkt wieder geladen werden, so dass das Spiel weitergespielt werden kann. Der zu diesem Zeitpunkt bestehende Spielzustand wird ohne Nachfrage verworfen.

Ein Laden und Speichern während einer laufenden Animation muss nicht möglich sein bzw. kann nach deren Ende ausgeführt werden.

Die Formate der benötigten Dateien sollen selbst gewählt und ausführlich in der Doku beschrieben werden!

#!/bin/sh
# Stand: 06. August 2013

# dieses skript schreibt alle .html dateien aus dem verzeichnis, in dem das skript liegt (möglichst das verzeichnis,
# in das das galileo-openbook-zip-archiv entpackt wurden)
# in die datei alle.htm im selben verzeichnis, bereinigt diese (geht dabei nach einem galileo
# openbook-spezifischen muster vor - das kann siche aendern!!!) und wandelt das resultat in eine pdf-datei openbook.pdf um,
# wobei es eine css-datei beruecksichtigt, die aus dem normalen galileo-style und der datei archiv-verzeichnis/mod.css , die
# eventuell noch angelegt werden muss, zusammengesetzt ist.

# die css-datei archiv-verzeichnis/mod.css sollte folgendes enthalten (ohne die rauten,
# das koennte sich im laufe der zeit veraendern!!!):
# body {visibility:hidden;background:none;width:100%;padding:0;margin:0;}
# table, tr, td{padding:0;margin:0; width:auto;}
# div.main, .box {visibility:visible;margin:0;padding:0;width:100%;}
# .box {border:none; margin-top:-100; padding-bottom:50px;}
# dd {display:none;}

# start des skript-bodys
echo "Lege css-Datei ./user.css an ..."
cat ./common/galileo_open.css > ./user.css
cat ./mod.css >> ./user.css

echo "Kopiere alle html-Dateien in ./alle.htm ..."
HTMS="`ls *.html`"

for FILE in ${HTMS};
do
	if [ "$FILE" != "stichwort.html" ]; then
		# werfe die kommentare raus (alles zwischen <br><hr><a  und </form> )
		sed '/<br><hr><a /,/<\/form>/ d' ./$FILE > ./clean
		# werfe head und erste tabelle raus
		sed '/<html>/,/<\/table>/ d' ./clean > ./cleaner
		#fuege minimale kopfzeilen ein
		echo "<html><head><title></title></head><body>" > ./clean
		cat ./cleaner >> ./clean
		#saeubere die ausgabe ohne etwas auszugeben
		tidy -m ./clean 2>/dev/null
		#haenge es der alle beinhaltenden datei an
		cat ./clean >> ./alle.htm
	fi
done

#saeubere ausgabe ohne etwas auszugeben
tidy -m ./alle.htm 2>/dev/null

#loesche den anfang der datei
sed '/<!DOC/,/<\/head>/ d' ./alle.htm > ./clean

#fuege minimale kopfzeilen ein
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n<html>\n<head>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"user.css\">\n</head>" > ./alle.htm

#fuege restinhalt ein
cat clean >> ./alle.htm

echo "Wandele ./alle.html in ./openbook.pdf um ..."

# umwandeln von htm zu pdf
wkhtmltopdf -n -s A4 -d 200 ./alle.htm ./openbook.pdf

echo "Raeume auf ..."
rm ./clean
rm ./cleaner
rm ./alle.htm
rm ./user.css

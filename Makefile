PACKAGE = jukebox
VERSION = $(shell grep "^ *VERSIONSTRING" jukebox.pl |head -n 1 |grep -Eo [.0-9]+)


prefix		= usr
bindir 		= ${DESTDIR}/${prefix}/bin
appdir		= ${DESTDIR}/${prefix}/share/applications
datadir		= ${DESTDIR}/${prefix}/share
mandir		= ${DESTDIR}/${prefix}/share/man
docdir		= ${DESTDIR}/${prefix}/share/doc/$(PACKAGE)-${VERSION}
menudir		= ${DESTDIR}/${prefix}/lib/menu
iconsdir	= ${DESTDIR}/${prefix}/share/icons/hicolor

DOCS=AUTHORS COPYING README NEWS INSTALL layout_doc.mkd

MARKDOWN= markdown

all: install

clean:
	rm -rf dist/

install:
	mkdir -p "$(bindir)"
	mkdir -p "$(datadir)/jukebox/"
	mkdir -p "$(docdir)"
	mkdir -p "$(mandir)/man1/"
	install -pm 644 $(DOCS) "$(docdir)"
	install -pm 644 jukebox.1 "$(mandir)/man1/jukebox.1"
	install -d "$(datadir)/jukebox/pix/"
	install -d "$(datadir)/jukebox/pix/Papirus-Light"
	install -d "$(datadir)/jukebox/pix/Trinity"
	install -d "$(datadir)/jukebox/plugins/"
	install -d "$(datadir)/jukebox/layouts/"
	install -pDm 755 jukebox.pl 		"$(bindir)/jukebox"
	install -pm 755 iceserver.pl		"$(datadir)/jukebox/iceserver.pl"
	install -pm 644 *.pm			"$(datadir)/jukebox/"
	install -pm 644 jukeboxrc.default	"$(datadir)/jukebox/"
	install -pm 644 layouts/*.layout	"$(datadir)/jukebox/layouts/"
	install -pm 644 plugins/*.pm		"$(datadir)/jukebox/plugins/"
	install -pm 644 pix/Papirus-Light/*.*	"$(datadir)/jukebox/pix/Papirus-Light/"
	install -pm 644 pix/Trinity/*.*		"$(datadir)/jukebox/pix/Trinity/"
	install -pm 644 pix/*.*			"$(datadir)/jukebox/pix/"
	install -pDm 644 jukebox.desktop	"$(appdir)/jukebox.desktop"
	install -pDm 644 jukebox.appdata.xml	"$(datadir)/appdata/jukebox.appdata.xml"
	install -pDm 644 pix/jukebox.svg	"$(iconsdir)/scalable/apps/jukebox.svg"
	install -pDm 644 pix/jukebox16x16.svg	"$(iconsdir)/16x16/apps/jukebox.svg"
	install -pDm 644 pix/trayicon.png	"$(iconsdir)/20x20/apps/jukebox.svg"
	install -pDm 644 pix/jukebox32x32.svg	"$(iconsdir)/32x32/apps/jukebox.svg"
	install -pDm 644 pix/jukebox48x48.svg	"$(iconsdir)/48x48/apps/jukebox.svg"
	install -pDm 644 pix/jukebox64x64.svg	"$(iconsdir)/64x64/apps/jukebox.svg"
	$(MAKE) update-icon-cache

uninstall:
	rm -f "$(bindir)/jukebox"
	rm -rf "$(datadir)/jukebox/" "$(docdir)"
	rm -f "$(iconsdir)/scalable/apps/jukebox.svg" \
		"$(iconsdir)/16x16/apps/jukebox.svg" \
		"$(iconsdir)/20x20/apps/jukebox.svg" \
		"$(iconsdir)/32x32/apps/jukebox.svg" \
		"$(iconsdir)/48x48/apps/jukebox.svg" \
		"$(iconsdir)/64x64/apps/jukebox.svg"
	rm -f "$(appdir)/jukebox.desktop" "$(datadir)/appdata/jukebox.appdata.xml"
	rm -f "$(mandir)/man1/jukebox.1"
	$(MAKE) update-icon-cache

prepackage : all
	perl -pi -e 's!Version:.*!Version: '$(VERSION)'!' jukebox.spec
	mkdir -p dist/

dist: prepackage
	tar -czf dist/$(PACKAGE)-$(VERSION).tar.gz . \
		--transform=s/^[.]/$(PACKAGE)-$(VERSION)/ \
		--exclude=\*~ \
		--exclude=.git\* \
		--exclude=.\*swp \
		--exclude=./dist \
		&& echo wrote dist/$(PACKAGE)-$(VERSION).tar.gz

# release : same as dist, but exclude debian/ folder
release: prepackage
	tar -czf dist/$(PACKAGE)-$(VERSION).tar.gz . \
		--transform=s/^[.]/$(PACKAGE)-$(VERSION)/ \
		--exclude=\*~ \
		--exclude=.git\* \
		--exclude=.\*swp \
		--exclude=./dist \
		--exclude=./debian \
		&& echo wrote dist/$(PACKAGE)-$(VERSION).tar.gz

update_icon_cache = gtk-update-icon-cache -f -t $(iconsdir)
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk icon cache."; \
		$(update_icon_cache) ; \
	else \
		echo "*** Icon cache not updated. After (un)install, run this:"; \
		echo "***  $(update_icon_cache)" ; \
	fi


# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools eutils fcaps

DESCRIPTION="My TraceRoute, an Excellent network diagnostic tool"
HOMEPAGE="https://www.bitwizard.nl/mtr/"
SRC_URI="https://www.bitwizard.nl/mtr/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="gtk ipv6 ncurses"

RDEPEND="
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
	)
	ncurses? ( sys-libs/ncurses:0= )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	virtual/pkgconfig
"
DOCS=( AUTHORS NEWS SECURITY TODO )
FILECAPS=( cap_net_raw usr/sbin/mtr-packet )
PATCHES=(
	"${FILESDIR}"/${PN}-0.88-tinfo.patch
)

src_prepare() {
	default

	sed -i -e 's|m4_esyscmd(\[build-aux/git-version-gen .tarball-version\])|'"${PV}"'|g' configure.ac || die

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable ipv6) \
		$(use_with gtk) \
		$(use_with ncurses)
}

src_test() {
	[[ "$UID" = 0 ]] && default
}

pkg_postinst() {
	fcaps_pkg_postinst

	if use prefix && [[ ${CHOST} == *-darwin* ]] ; then
		ewarn "mtr needs root privileges to run.  To grant them:"
		ewarn " % sudo chown root ${EPREFIX}/usr/sbin/mtr"
		ewarn " % sudo chmod u+s ${EPREFIX}/usr/sbin/mtr"
	fi
}

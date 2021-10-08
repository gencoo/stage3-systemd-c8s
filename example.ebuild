inherit rhel8-a autotools flag-o-matic toolchain-funcs
CMAKE_MAKEFILE_GENERATOR=emake
CMAKE_BUILD_TYPE=RelWithDebInfo
MY_PR=${PVR##*r}
MY_PF=${P}-${MY_PR}

SRC_URI="${REPO_URI}/${MY_PF}.${DIST}.src.rpm"
${SRC_URI}
SANDBOX_WRITE="${HOME}/.bash_history"
SANDBOX_WRITE="/etc/:/var/lib/rpm/"
	tree ${ED}
	exit 0

	rm -f "${ED}"${_infodir}/dir

	gen_usr_ldscript -n

	diropts -m 0755 && dodir /etc/ssh/sshd_config.d

	insopts -m0755
	insinto $
	doins "${WORKDIR}"/

	exeinto ${_libexecdir}/
	doexe "${WORKDIR}"/

	newpamd

	fowners root:qubes
	fperms 2770

	systemd_dounit "${WORKDIR}"/'sshd@.service'

		cat <<-EOF >> "${ED}"//etc/pam.d/sudo-i
		session    optional     pam_keyinit.so force revoke
		EOF

	dosym <filename> <linkname>
	filter-flags '*-annobin-cc1' -fcf-protection -flto=auto '*-hardened-ld'
	append-cflags
	append-ldflags -Wl,--strip-all -Wl,--as-needed
		DESTDIR="${D}" \
		PREFIX="${EPREFIX}/usr" \
		LIBDIR="${EPREFIX}"/usr/$(get_libdir) \
		DOCDIR="${EPREFIX}"/usr/share/doc/${PF} \
		SESANDBOX="n" \
		--with-python=${PYTHON}

	# drop flags
	unset CFLAGS
	unset LDFLAGS
	unset ASFLAGS
	unset CPPFLAGS

	[[ $(tc-arch) == "amd64" ]] && myconf+=( --enable-fpm=64bit )

pkg_setup() {
	export mypkg_gui="athena"
}

src_unpack() {
	rhel_src_unpack ${A}
}

src_unpack() {
	rhel_unpack ${A} && unpack ${WORKDIR}/*.tar.*
	rpmbuild --rmsource -bp $WORKDIR/*.spec --nodeps
	sed -i "/patch5 -p1/d" ${WORKDIR}/*.spec
	sed -i 's/EFI_VENDOR=fedora/EFI_VENDOR=qubes/g' ${S}/xen/Makefile
	sed -i '332,334d' ${WORKDIR}/rpm.spec
	sed -i "/%files plugin-selinux/,+2d" ${WORKDIR}/rpm.spec
	sed -i '1a%define _build_id_links none' ${WORKDIR}/rpm.spec
	sed -i "/--with-selinux/d" ${WORKDIR}/rpm.spec
	sed -i 's?^.*py3_install.*$?/usr/bin/python setup.py install -O1 --skip-build --root $D?' ${WORKDIR}/rpm.spec
"${FILESDIR}"
}

src_prepare() {
	default
	eapply ${WORKDIR}
}

src_configure() { :; }

src_compile() {
	if [ -f Makefile ] || [ -f GNUmakefile ] || [ -f makefile ] ; then
		rm -f Makefile GNUmakefile makefile
	fi
}

src_test() {
	emake test
}

src_install() {
	rpmbuild --short-circuit -bi $WORKDIR/*.spec --nodeps --noclean --nocheck --nodebuginfo --buildroot=$D
	default
}

pkg_preinst() {
	return
}

pkg_postinst() {
	return
}

pkg_prerm() {
	return
}

pkg_postrm() {
	return
}

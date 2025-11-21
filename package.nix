{ stdenv, lib, git}:

stdenv.mkDerivation rec {
  pname = "Wootility-Test";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "SauceSeeker06";
    repo = https://github.com/${owner}/${pname};
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  meta = with lib; {
    description = "My C application";
    homepage = "https://github.com/github-owner/${pname}";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
# Devcontainer for CompCert

[![CompCert devcontainer build](https://github.com/TheCBaH/ocaml-devcontainer/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/TheCBaH/ocaml-devcontainer/actions/workflows/build.yml)

Devcontainer to build and check [CompCert](https://compcert.org/), the
formally-verified C compiler, vendored here as the `modules/CompCert`
submodule, using [Rocq](https://rocq-prover.org/) (formerly Coq).

CompCert is not free software; this non-commercial distribution may only be used
for evaluation, research, educational and personal purposes. See
[modules/CompCert/LICENSE](modules/CompCert/LICENSE) for details.

## Get started
* [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=628173356)
* Then, inside the devcontainer:
  * `make compcert` configure and build CompCert (proof + `ccomp`) for the
    native architecture (x86_64-linux or aarch64-linux)
  * `make compcert-check-proof` recheck the proof with `coqchk`/`rocqchk`
  * `make compcert-test` run the CompCert test suite

List of OCaml/opam packages (including Rocq and Menhir) installed by the
devcontainer is located in
[.devcontainer/devcontainer.json](https://github.com/TheCBaH/ocaml-devcontainer/blob/devel/.devcontainer/devcontainer.json).

CI builds and checks CompCert natively across the OCaml version/platform
matrix (see [.github/workflows/build.yml](.github/workflows/build.yml) and
[.github/workflows/ocaml-versions.yml](.github/workflows/ocaml-versions.yml)),
running each platform on a matching native runner.

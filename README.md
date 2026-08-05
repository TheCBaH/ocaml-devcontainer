# Devcontainer for OCaml

[![OCaml devcontainer example](https://github.com/TheCBaH/ocaml-devcontainer/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/TheCBaH/ocaml-devcontainer/actions/workflows/build.yml)

Devcontainer to create [OCaml](https://ocaml.org/) development environment.

## Get started
* [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=628173356)
* run
  * `make hello` build and run hello world example

List of additional OCaml packages located in [.devcontainer/devcontainer.json](https://github.com/TheCBaH/ocaml-devcontainer/blob/devel/.devcontainer/devcontainer.json#L19).

## CompCert

This repo also vendors [CompCert](https://compcert.org/), the formally-verified C
compiler, as the `modules/CompCert` submodule, and can build and check it using
[Rocq](https://rocq-prover.org/) (formerly Coq).

CompCert is not free software; this non-commercial distribution may only be used
for evaluation, research, educational and personal purposes. See
[modules/CompCert/LICENSE](modules/CompCert/LICENSE) for details.

The default devcontainer does not install Rocq, to keep the plain OCaml
environment lightweight. To build CompCert, set these environment variables
before bringing up the devcontainer (see the `compcert` job in
[.github/workflows/build.yml](.github/workflows/build.yml) for a worked example):

```sh
export OCAML_EXTRA_PACKAGES="rocq-prover menhir"
export OCAML_SYSTEM_PACKAGES="libgmp-dev pkg-config"
export OCAML_OPAM_REPOSITORIES="rocq-released https://rocq-prover.org/opam/released"
```

Then, inside the devcontainer:

* `make compcert` configure and build CompCert (proof + `ccomp`) for the native
  architecture (x86_64-linux or aarch64-linux)
* `make compcert-check-proof` recheck the proof with `coqchk`/`rocqchk`
* `make compcert-test` run the CompCert test suite

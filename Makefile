all:
	ocaml pkg/pkg.ml build -n mirage-net
	ocaml pkg/pkg.ml build -n mirage-net-lwt

clean:
	ocaml pkg/pkg.ml clean -n mirage-net
	ocaml pkg/pkg.ml clean -n mirage-net-lwt

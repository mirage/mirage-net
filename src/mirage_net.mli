(*
 * Copyright (c) 2011-2015 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2013-2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2013      Citrix Systems Inc
 * Copyright (c) 2018      Hannes Mehnert <hannes@mehnert.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Network devices

    [Mirage_net] defines the signature for MirageOS network devices.

    {e Release %%VERSION%% } *)

type error = Mirage_device.error
(** The type for IO operation errors *)

val pp_error: error Fmt.t
(** [pp_error] pretty-print network errors. *)

type stats = {
  mutable rx_bytes: int64;
  mutable rx_pkts: int32;
  mutable tx_bytes: int64;
  mutable tx_pkts: int32;
}
(** The type for frame statistics to track the usage of the device. *)

(** {1 Networking} *)

(** A network interface that serves Ethernet frames. *)
module type S = sig

  type error = private [> Mirage_device.error]
  (** The type for network interface errors. *)

  val pp_error: error Fmt.t
  (** [pp_error] is the pretty-printer for errors. *)

  type buffer
  (** The type for memory buffers. *)

  type macaddr
  (** The type for unique MAC identifiers for the network interface. *)

  include Mirage_device.S

  val write: t -> buffer -> (unit, error) result io
  (** [write net buf] outputs [buf] to network interface [net]. *)

  val writev: t -> buffer list -> (unit, error) result io
  (** [writev net bufs] output a list of buffers to the network interface [net]
      as a single packet. *)

  val listen: t -> (buffer -> unit io) -> (unit, error) result io
  (** [listen net fn] is a blocking operation that calls [fn buf] with
      every packet that is read from the interface. The function can
      be stopped by calling [disconnect] in the device layer. *)

  val allocate_frame : t -> buffer
  (** [allocate_frame net] allocates a single frame which can be filled
      and transmitted via [write] on the same interface [net]. The reason for
      this function is that the network interface is aware of its
      memory-alignment requirements (i.e. if it requires page-alignment).
      Using [write] with a buffer allocated from a different network device
      leads to undefined behaviour. *)

  val mac: t -> macaddr
  (** [mac net] is the MAC address of [net]. *)

  val mtu: t -> int
  (** [mtu net] is the Maximum Transmission Unit of [net]. *)

  val get_stats_counters: t -> stats
  (** Obtain the most recent snapshot of the interface statistics. *)

  val reset_stats_counters: t -> unit
  (** Reset the statistics associated with this interface to their
      defaults. *)

end

module Stats : sig
  val create: unit -> stats
  (** [create ()] returns a fresh set of zeroed counters *)

  val rx: stats -> int64 -> unit
  (** [rx t size] records that we received a packet of length [size] *)

  val tx: stats -> int64 -> unit
  (** [tx t size] records that we transmitted a packet of length [size] *)

  val reset: stats -> unit
  (** [reset t] resets all packet counters in [t] to 0 *)
end

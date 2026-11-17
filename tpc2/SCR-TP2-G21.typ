#set text(lang: "pt")
#import "@preview/fine-lncs:0.6.5": author, institute, lncs, proof, theorem

#set text(lang: "pt")

// #set image()

#let inst_uminho = institute(
  "Universidade do Minho",
  addr: "",
)

#show: lncs.with(
  title: "TP 1: Nível de Ligação Lógica - Ethernet e Protocolo ARP; Redes sem Fios (IEEE 802.11)",
  // Opt.: Set this, if the title is too long to avoid linebreaks in the header of odd pages
  // running-title: "Short version of contribution title",
  // running-author: "Override the default author shortening",
  authors: (
    author(
      "Pedro Rosa",
      insts: (inst_uminho),
      oicd: "a116276",
    ),
    author(
      "David Lobo",
      insts: (inst_uminho),
      oicd: "a114812",
    ),
    author("Esteban Yepez", insts: (inst_uminho), oicd: "a117634"),
  ),
  // bibliography: bibliography("refs.bib"),
  // optional configuration of page (takes all page parameter)
  // page_config: (paper: "a4")
)


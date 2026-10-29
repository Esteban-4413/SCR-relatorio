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

= Parte 1: Nível de Ligação Lógica - Ethernet e Protocolo ARP
== Captura e análise de tramas ethernet

#figure(image("imgs/figura1.png", width: 75%), caption: [Estrutura genérica de uma Trama Ethernet])<fig:trama_base>

=== Pergunta 1
Anote os endereços Ethernet ou MAC de origem e de destino de trama capturado com o pedido HTTP. Identifique a que sistemas se referem. Justifique.

#figure(
  image("imgs/ethernet.png", width: 75%),
  caption: [Cabeçalho Ethernet da trama com o pedido `HTTP GET`],
)<fig:eth_req>

*Resposta.*
Conforme observável na @fig:eth_req
- *Origem:* `1e:6c:c2:c2:3a:2c`. É a interface _Wi-Fi_ (`en0`) do computador onde se fez a captura, o endereço IP `172.26.193.235`. O _Wireshark_ mostra que o bit LG vale 1, ou seja, não é o endereço de fábrica da placa. É um endereço aleatório gerado pelo sistema operativo (recurso de privacidade do macOS).

- *Destino:* `d4:7f:35:16:e2:9f`, identificado pelo _Wireshark_ como `Cisco_16:e2:9f` (bit LG 0, endereço de fábrica; bit IG 0, _unicast_). É o equipamento de primeiro salto da rede (router, ou o AP da _Eduroam_) e não o servidor _web_.

- *Justificação:* o IP destino (`193.136.9.240`, marco.uminho.pt) é de outra rede. Como o servidor não está na rede local, a trama é entregue ao _router_, que a encaminha. Os endereços MAC têm significado apenas na ligação local (mudam em cada salto), enquanto os IP são fim-a-fim.

=== Pergunta 2
Analisando os campos do cabeçalho da trama capturada, diga, justificando, qual o protocolo encapsulado nessa trama.

- Resposta: O protocolo encapsulado é o IPv4. O campo _Type_ do cabeçalho Ethernet na @fig:eth_req tem o valor `0x0800` (visível nos bytes 12-13 da trama, `08 00`, linha `0000` do `hex dump`), valor que identifica o protocolo IPv4.

=== Pergunta 3
Quantos bytes são usados desde o início da trama até ao caractere ASCII "G" do método `HTTP GET`? Calcule e indique, em percentagem, a sobrecarga (_overhead_) introduzida pela pilha protocolar no envio do `HTTP GET` (considere os _bytes_ ocupados pela camada física e pelo FCS, indicados na Figura 1).


#figure(
  image("imgs/IP.png", width: 75%),
  caption: [Detalhe do cabeçalho IPv4],
)<fig:ipv4_det>

#figure(
  image("imgs/TCP.png", width: 75%),
  caption: [Detalhe do cabeçalho TCP],
)<fig:tcp_det>

#figure(
  image("imgs/GET.png", width: 75%),
  caption: [Início do _payload_ com o método `GET`],
)<fig:get_det>

#figure(caption: [Cálculo dos bytes consumidos até ao "G" do `HTTP`])[
  #table(
    columns: (auto, auto, 1fr),
    // align: left + buttom,
    table.hline(),
    table.header[Camada][_Bytes_][Evidência],
    table.hline(),
    [Ethernet II (cabeçalho)], [14], [$6 + 6 + 2$],
    [IPv4], [20], [_Header length_: 20 bytes],
    [TCP], [32], [_Header length_: 32 bytes ($20 + 12$ de opções: NOP, NOP, _Timestamps_ - @fig:tcp_det)],
    [Total até o "G"], [66],
    table.hline(),
  )
]<tab:overhead>

Tal e como está ilustrado na @tab:overhead o "G" (`47`) está no offset `0x42` = 66 da trama (linha `0040` do _hex dump_: `cd 1d 47 45 54` ilustrado na @fig:get_det), por isso são usados 66 _bytes_ antes do "G" (74 se contares o preâmbulo + SFD de 8 _bytes_).

*Cálculo da Sobrecarga:*
#list(
  [*Payload* `HTTP` (TCP _payload_) = 415 B. Confere: $66 + 415 = 481 B$ (tamanho da trama).],
  [Camada física: preâmbulo $7 B + "SFD" 1 B = 8 B$; $"FCS" = 4 B$.],
  [Tamanho total enviado: $8 + 481 + 4 = 493 B$],
  [nSobrecarga = $8 + 66 + 4 = 78 B$ ],
)
Sobrecarga = $78 / 493 approx 15,8 %$

=== Pergunta 4
Quais são os endereços Ethernet da origem e destino? A que sistemas de rede correspondem? Justifique. (trama com o primeiro _byte_ da resposta `HTTP`)

#figure(
  image("imgs/ethernet113667.png", width: 75%),
  caption: [Cabeçalho Ethernet da tram 11367 (Resposta `HTTP`)],
)<fig:eth_resp>

*Resposta (trama 11367, ilustrada na @fig:eth_resp)*
- *Origem:* `d4:7f:35:16:e2:9f` (`Cisco_16:e2:9f`, bit LG 0: endereço de fábrica). É o _router_ da rede local, que entrega ao computador a resposta do servidor.
- *Destino:* `1e:6c:c2:c2:3a:2c`, o computador do aluno (`172.26.193.235`), com bit LG 1 (enderço privado, o mesmo que era a origem do pedido)
- *Justificação:* são os endereços do pedido com os papéis trocados (_hex dump_: _bytes_ 0-5 = `1e 6c c2 c2 3a 2c`, _bytes_ 6-11 = `d4 7f 35 16 e2 9f`). Os IP mantêm-se fim-a-fim (`193.136.9.240` → `172.26.193.235`), mas os MAC são os do último salto: o servidor está noutra rede, logo o MAC de origem não é o dele. O TTL de $61$ (`0x3d`), inferior ao valor inicial típico de $64$, é coerente com a travessia de routers.

=== Pergunta 5
Atendendo ao conceito de desencapsulamento protocolar, identifique os vários protocolos contidos na trama recebida. Represente-os num esquema por camadas.

#figure(
  image("imgs/hypertext-transfer-protocol.png", width: 75%),
  caption: [Detalhe do desencapsulamento protocolar no Wireshark],
)<fig:http_resp>

*Resposta*: De baixo para cima na arquitetura, os protocolos evidenciados na @fig:http_resp são:

```text
+---------------------------------------------------+
| Aplicação   : HTTP  (HTTP/1.1 301 Moved           |
|               Permanently; corpo text/html)       |  ← payload do TCP (539 B)
+---------------------------------------------------+
| Transporte  : TCP   (porta 80 → 64796, Ack 416)   |  ← payload do IP
+---------------------------------------------------+
| Rede        : IPv4  (193.136.9.240 →              |  ← payload da Ethernet
|                      172.26.193.235, protocolo 6) |
+---------------------------------------------------+
| Ligação     : Ethernet II (Type 0x0800)           |
+---------------------------------------------------+
```
Durante o desencapsulamento, a placa de rede verifica o cabeçalho Ethernet e, constatando tratar-se do protocolo IPv4 (Type `0x0800`), entrega o payload à camada de Rede. O IPv4 (Protocolo 6) processa e entrega ao TCP, que encaminha finalmente a resposta para a aplicação HTTP.

== Protocolo ARP

#figure(image("imgs/topologiaFixed.png", width: 75%), caption: [Topologia da rede])

=== Pergunta 6
Abra uma consola no host onde efetuou o ping. Observe o conteúdo da tabela ARP com o comando `arp`.
- a. Com ajuda do manual `arp` (`man arp`), interprete sucintamente o significado de cada uma das colunas da tabela.
- b. Indique, justificando, qual o equipamento da rede em questão que poderá apresentar a maior tabel ARP em termos de número de entradas.
- c. Realize as operações necessárias para completar a tabela ARP identificada na alínea anterior. Indique como procedeu e apresente essa tabela completa.

#figure(
  image("imgs/prob2.png", width: 75%),
  caption: [Verificação inicial da tabela ARP],
)<fig:arp_inicial>

- *a)* Colunas (`man arp`): _Address_ (IP do vizinho), _HWtype_ (tipo de ligação, normalmente `ether`), _HWaddress_ (endereço MAC resolvido), _Flags_ Mask (`C` = entrada completa/dinâmica; `M` = permanente) e _Iface_ (interface de rede).
- *b)* Em princípio, o equipamento om a maor tabela será um dos _routers_, por concentrar o tráfego inter-redes. O _router_ $R_A$ liga-se diretamente à LAN do Depto A (4 PCs + 1 servidor = 5 entradas) e ainda liga-se ao _router_ $R_B$, ou seja, até 6 entradas. O $R_B$ só tem o hub (3 PCs) + $R_A$ + $R_C$ (5). Justifica com o que vês na topologia que montaste.
- *c)* Para completar a tabela do router $R_A$ (n7), efetuaram-se comandos ping dirigidos a todos os vizinhos diretos, o que obrigou o sistema a gerar pedidos ARP e registar as respostas na cache.

```bash
for i in 21 22 23 24; do ping -c 1 10.0.0.$1; done
ping -c 1 10.0.1.2
arp
```

#figure(
  image("imgs/probBn7.png", width: 75%),
  caption: [Tabela ARP do router `n7`],
)<fig:arp_n7>

#figure(caption: [Tabela ARP de `n7`])[
  #table(
    columns: (auto, auto, auto),
    // align: left + buttom,
    table.hline(),
    table.header[_Address_][_HWaddress_][_Iface_],
    table.hline(),
    [`10.0.0.20`], [`00:00:00:aa:00:00`], [`eth0`],
    [`10.0.0.21`], [`00:00:00:aa:00:01`], [`eth0`],
    [`10.0.0.22`], [`00:00:00:aa:00:02`], [`eth0`],
    [`10.0.0.23`], [`00:00:00:aa:00:03`], [`eth0`],
    [`10.0.0.24`], [`00:00:00:aa:00:04`], [`eth0`],
    [`10.0.1.2`], [`00:00:00:aa:00:07`], [`eth1`],
    table.hline(),
  )
]<tab:arp_completa>

=== Pergunta 7
Qual é o valor hexadecimal dos endereços origem e destino na trama Ethernet que contém o ARP Request? Como interpreta e justifica o endereço destino usado?

#figure(
  image("imgs/prob32.png", width: 75%),
  caption: [Conteúdo do ARP _request_: _Who has 10.0.0.1?_],
)<fig:arp_req>
*Resposta (trama 305 - @fig:arp_req).*

- Origem: `00:00:00:aa:00:01` (n5).
- Destino: `ff:ff:ff:ff:ff:ff` (_broadcast_).

O nó de origem conhece o endereço IP do destinatário, mas precisa de descobrir o endereço MAC associado. Ao utilizar broadcast, a mensagem é difundida a todos os dispositivos no domínio da rede local, garantindo que o detentor do IP correto a receba e emita a resposta.

=== Pergunta 8
Qual o valor hexadecimal no campo Tipo da trama Ethernet? O que indica?

*Resposta.* `0x0806`. Indica que o _payload_ da trama é uma mensagem ARP.

=== Pergunta 9
Observando a mensagem ARP, como pode saber que se trata efetivamente de um pedido ARP? Identifique o tipo de endereços contidos na mensagem ARP.

*Resposta.* O campo _Opcode_ da @fig:arp_req tem o valor 1 (_request_). A mensagem contém endereços de _hardware_, neste caso Ethernet/MAC (_Hardware type_ 1, 6 _bytes_ ou 48 bits), e endereços de protocolo, neste caso IPv4 (_Protocol type_ `0x0800`, 4 _bytes_ ou 32 _bits_).

=== Pergunta 10
Explicite, em linguagem comum, que tipo de pedido ou pergunta é feita pelo host de origem à rede?

*Resposta.* "Quem tem o endereço IP 10.0.0.1? Respondam a `10.0.0.21` (MAC `00:00:00:aa:00:01`)".Como o MAC de destino é o valor procurado, o campo Target MAC é transmitido a zeros (`00:00:00:00:00:00`).

=== Pergunta 11
Localize a mensagem ARP que é a resposta ao pedido ARP efetuado.

#figure(
  image("imgs/prob33.png", width: 75%),
  caption: [ARP _reply_],
)<fig:arp_rep>
*Resposta*
- *a)* Opcode = 2 (_reply_): indica que é uma resposta ARP (@fig:eth_req).
- *b)* A resposta está no campo _Sender MAC address_ da mensagem de resposta (o MAC de quem tinha o IP perguntado).
- *c)* A resposta é _unicast_, porque o MAC do requerente já é conhecido (veio no pedido, no _Sender MAC_), não é necessário difundir.

=== Pergunta 14
Verifique se o ping feito ao segundo PC originou pacotes ARP e justifique a situação observada.

*Resposta.* Não originou. Os destinos dos pings (`10.0.3.20` e `10.0.3.21`) localizam-se numa sub-rede diferente. Para os alcançar, o tráfego tem de ser enviado ao gateway da LAN (`10.0.0.1`). Uma vez que o MAC do gateway já tinha sido resolvido no primeiro ping e guardado na cache ARP local (visível pela flag C na @fig:arp_inicial), o sistema operativo reutilizou a entrada existente.

=== Pergunta 15
Identifique na mensagem ARP os campos que permitem definir o tipo e o tamanho dos endereços das camadas de rede e de ligação lógica que se pretendem mapear. Justifique os valores apresentados nesses campos.

*Resposta* (Frames 305 a 306)
#figure(caption: [Mapeamento dos campos ARP], table(
  columns: 3,
  table.hline(),
  table.header[Campo][Valor][Signinficado],
  table.hline(),
  [`Hardware type`], [1], [Ethernet (camada de ligação)],
  [`Protocol`], [`0x0800`], [IPv4 (camada de redes)],
  [`Hardware size`], [6], [$"Endereço MAC" = 6 "bytes"$],
  [`Protocol size`], [4], [$"Endereço IPv4" = 4 "bytes"$],
  table.hline(),
))<tab:campos_arp>

== Domínios de colisão
=== Pergunta 15
Através da opção tcpdump, verifique e compare como flui o tráfego nas diversas interfaces dos vários dispositivos no departamento A (LAN comutada) e no departamento B (LAN partilhada) quando gera tráfego intra-departamento.

*Resposta:*

Com base na análise de tráfego efetuada com a ferramenta tcpdump:

- Departamento B (LAN partilhada através de _Hub_): Como o _hub_ atua na camada física (repetindo o sinal elétrico recebido para todas as portas ativas), verificou-se que todos os _hosts_ do departamento escutaram o tráfego ICMP e ARP gerado. Isto comprova que os dispositivos no Departamento B partilham a mesma largura de banda e constituem um único e vasto domínio de colisão.

- Departamento A (LAN comutada através de Switch): O _switch_ opera na camada de ligação lógica construindo uma tabela de comutação (auto-aprendizagem). Após o registo, as tramas _unicast_ foram encaminhadas apenas para a porta do dispositivo de destino. Equipamentos alheios à comunicação não detetaram o tráfego, evidenciando que o _switch_ divide a rede de modo a que cada uma das suas portas forme o seu próprio domínio de colisão isolado (a exceção sendo o tráfego inicial de broadcast ARP, que é obrigatoriamente difundido por todos).

=== Pergunta 16
Apresente a tabela de comutação completa do switch do departamentos

*Resposta:* A tabela de comutação associa o endereço MAC de cada equipamento ligado à sua respetiva porta no _switch_:

#figure(caption: [Tabela de comutação do _switch_ do Depto A], table(
  columns: (auto, auto, auto),
  table.hline(),
  table.header([Enderço MAC], [Porta], [Equipamento]),
  table.hline(),
  [`00:00:00:aa:00:04`], [P1], [n1],
  [`00:00:00:aa:00:03`], [P2], [n2],
  [`00:00:00:aa:00:02`], [P3], [n3],
  [`00:00:00:aa:00:00`], [P4], [n4],
  [`00:00:00:aa:00:01`], [P5], [n5 (servidor)],
  [`00:00:00:aa:00:05`], [P6], [n7 (`eth0`, ligação ao _router_ $R_A$)],
  table.hline(),
))<tab:switch_mac>

= Redes sem fio (IEEE 802.11)

== Accesso Rádio

#figure(
  image("imgs/resposta(Q1&Q2&Q3&Q4)P2.png", width: 75%),
  caption: [Parâmetros fisicos registados],
)<fig:radio_info>

=== Pergunta 1
Identifique em que frequência do espectro está a operar a rede sem fios, e o canal que corresponde a essa frequência.

*Resposta:* Frequência e Canal: Analisando a secção "802.11 radio information" no Wireshark (@fig:radio_info), identificámos que a rede sem fios está a operar na frequência de 2412 MHz. Verificámos também que esta frequência corresponde ao Canal 1.

=== Pergunta 2
Identifique a versão da norma IEEE 802.11 que está a ser usada.

*Resposta:* Versão da Norma: Através do campo "PHY type", constatámos que a versão da norma IEEE 802.11 que está a ser usada na trama capturada é a 802.11b (HR/DSSS).

=== Pergunta 3
Qual o débito que foi enviada a trama escolhida? Será que esse débito corresponde ao débito máximo a que a interface _Wi-Fi_ pode operar? Justifique.

#figure(
  image("imgs/resposta(Q3&Q4)P2.png", width: 75%),
  caption: [],
)<fig:signal_metrics>

*Resposta:* Débito da Trama: Observámos que a trama escolhida foi enviada a um débito (Data rate) de 1.0 Mb/s (@fig:signal_metrics).

Justificação do Débito Máximo: Concluímos que este valor não corresponde ao débito máximo a que a interface Wi-Fi pode operar. A norma 802.11b suporta velocidades teóricas até 11 Mb/s. O envio a 1.0 Mb/s justifica-se pelo facto
de se tratar de uma trama de gestão (um Beacon); estas tramas são transmitidas intencionalmente na taxa base mais baixa para maximizar o alcance da propagação do sinal e garantir que todos os dispositivos
na vizinhança consigam ouvi-las e descodificá-las com sucesso, independentemente da distância.

=== Pergunta 4
Verifique qual a força do sinal (_signal strength_) e a qualidade expectável de receçao da tram, tendo em conta a tabela apresentada em Anexo.

*Resposta:* Força do Sinal e Qualidade: Verificámos na captura que a força do sinal (Signal strength) recebido é de -46 dBm. Além disso, a análise indica um nível de ruído (Noise level) de -93 dBm, o que resulta
numa relação Sinal/Ruído (Signal/noise ratio) de 47 dB. Tendo em conta o que nos é pedido para verificar face à tabela em Anexo, e perante valores tão favoráveis (um sinal forte de -46 dBm e
um excelente SNR de 47 dB), concluímos que a qualidade expectável de receção da trama é classificada como excelente, garantindo uma transmissão muito fiável e sem falhas.

== _Scanning_ Passivo e _Scanning_ Ativo

=== Pergunta 5
Selecione a *trama beacon* nr. 100+NG, sendo NG o seu número de grupo. Esta trama pertence a que tipo de tramas 802.11? Indique o valor dos seus identificadores de tipo e de subtipo. EM que parte concreta do cabeçalho da trama estão especificados?

#figure(
  image("imgs/respostaQ5P2.png", width: 75%),
  caption: [Subtipos do _Frame Control_ em tramas de gestão],
)<fig:beacon_type>
Type: Management frame (0)
Subtype: 8

*Conclusão:* A combinação destes dois campos resulta na classificação agregada que observámos na linha destacada a azul, identificando o pacote completo como "Type/Subtype: Beacon frame (0x0008)" mostrada na @fig:beacon_type.

=== Pergunta 5
Para a trama acima, identifique todos os enderços MAC em uso. Que conclui quanto à sua origem e destino?

#figure(
  image("imgs/respostaQ6P2.png", width: 75%),
  caption: [Mapeamento de endereços para a emissão de Beacons],
)<fig:beacon_addr>

Origem (Source / BSSID): 74:9b:e8:f3:9a:46. Identificado pelo Wireshark como HitronTechno_f3:9a:46, que verificámos corresponder ao endereço MAC do Ponto de Acesso (AP) responsável pela emissão da trama beacon.

Destino (Destination): ff:ff:ff:ff:ff:ff. Trata-se do endereço físico de Broadcast.

Conclusão: Concluímos que a trama é gerada por um Ponto de Acesso (AP) e enviada para o endereço de Broadcast, de forma a ser recebida por todas as estações (STA) na sua área de cobertura, servindo o
propósito de anunciar a presença da rede e os seus parâmetros.

=== Pergunta 6
Qual o intervalo de tempo previsto entr tramas _beacon_ consecutivas? Na prática, a periodicidade de tramas _beacon_ provenientes do mesmo AP é verificada com precisão? Justifique.

#figure(
  image("imgs/respostaQ7P2.png", width: 75%),
  caption: [Intervalo estipulado para emissões de Beacon],
)<fig:beacon_interval>

Intervalo previsto: O valor que analisámos (Beacon Interval) no cabeçalho de gestão é de 0.102400 segundos (102,4 milissegundos).

Justificação: As redes sem fios 802.11 utilizam o mecanismo de contenção e acesso ao meio CSMA/CA. Sabemos que, antes de emitir o beacon, o AP tem de escutar o meio. Se o canal sem fios estiver ocupado por outra
transmissão no momento agendado, o AP é forçado a aguardar até que o meio fique livre, o que verificámos introduzir pequenos atrasos na periodicidade destas tramas.

=== Pergunta 8
Face ao endereçamento usado, indique a que sistemas são endereçadas ambas as trams e explique qual o propósito das mesmas?

#figure(
  image("imgs/respostaQ8P2.png", width: 75%),
  caption: [Identificador SSID incluído nos parâmetros do _Beacon_],
)<fig:ssid_tag>

Resposta: Através da captura (@fig:ssid_tag) que nos foi fornecida, identificámos o SSID FlyingNet.

Modo de obtenção (Filtro): Para isolarmos estas tramas, utilizámos o filtro de visualização `wlan.fc.type_subtype == 8` no Wireshark, o que nos permitiu selecionar apenas as tramas de gestão do subtipo Beacon.

Modo de obtenção (Análise): Extraímos o nome específico da rede selecionando um destes pacotes e expandindo a secção IEEE 802.11 Wireless Management > Tagged parameters, localizando depois o campo Tag: SSID parameter set.

== Processo de Associação

=== Pergunta 9
Identifique uma sequência de tramas que corresponda a um processo de associação completo entre a STA e o AP, incluindo a fase de autenticação.

#figure(
  image("imgs/respostaQ9P2.png", width: 75%),
  caption: [Interações de _Scanning_ Ativo através de _Probe Request/Response_],
)<fig:probe_can>

Tramas Identificadas: Na captura fornecida (@fig:probe_can), conseguimos observar um exemplo claro de probing ativo através da trama 2178 (Probe Request), enviada pela estação de origem `AltoBeam_08:32:99`, que é
imediatamente seguida pelas tramas 2179 e 2180 (Probe Response), enviadas pelo AP TpLink_31:e2:39 como resposta direta. Outro par evidente que encontrámos é o Probe Request da trama 2068 (estação HP_d0:a0:11) e as respetivas
respostas nas tramas 2070 e 2071.

Probe Request (Endereçamento): Como observámos na coluna "Destination" da captura (ex: pacotes 2068 e 2178), esta trama é endereçada para o MAC de Broadcast (`ff:ff:ff:ff:ff:ff`).

Probe Request (Propósito): O objetivo é o dispositivo cliente efetuar um scanning ativo, enviando um pedido a todos os dispositivos para descobrir as redes sem fios disponíveis na vizinhança ou procurar um SSID específico.

Probe Response (Endereçamento): Verificámos que a trama (ex: pacotes 2070, 2179 ou o detalhe do pacote 2035) é endereçada em Unicast diretamente para o endereço MAC específico da estação que iniciou o
pedido (ex: HP_d0:a0:11, AltoBeam_08:32:99 ou fe:bd:a5:05:6c:84).

Probe Response (Propósito): O objetivo é o Ponto de Acesso (AP) responder de forma direcionada ao dispositivo requerente, confirmando a sua presença na rede e fornecendo-lhe os parâmetros de
comunicação (como SSID, canais e taxas suportadas).


=== Pergunta 10
Efetue um diagrama que ilustre, com as tramas identificadas na alínea anterior, a sequênciaa de todas as trams trocadas no processo de autenticação e associação entre o STA e o AP.

#figure(
  image("imgs/resposta(Q10&Q11)P2.png", width: 75%),
  caption: [Sequência completa de autenticação e associação (_Handshake_)],
) <fig:handshake>
Sequência de Tramas Identificada: Com base na print que tirámos (@fig:handshake), conseguimos observar várias sequências completas de associação. Um exemplo claro corresponde ao conjunto das tramas 2042, 2044, 2046 e 2048, trocadas entre a estação `fe:bd:a5:05:6c:84` e o AP `HitronTechno_f3:9a:...` para a rede SSID "FlyingNet".

Detalhamento da Sequência:

1. Trama 2042: Authentication (da STA `fe:bd...` para o AP `HitronTechno...`).
2. Trama 2044: Authentication (do AP `HitronTechno...` para a STA `fe:bd...`).
3. Trama 2046: Association Request (da STA `fe:bd...` para o AP `HitronTechno...`).
4. Trama 2048: Association Response (do AP `HitronTechno...` para a STA `fe:bd...`).

Outros exemplos visíveis: Notámos que a mesma sequência completa também é verificável para a estação `Apple_71:41:a1` (tramas 10365, 10368, 10372, 10376) e para a
estação `AzureWaveTec_0f:0e:...` (tramas 10530, 10532, 10536, 10538).

== Transferência de Dados

=== Pergunta 11
Diagrama de Sequência (Exemplo com a STA fe:bd:a5:05:6c:84):

```
    STA (fe:bd:a5:05:6c:84)                      AP (HitronTechno)
          |                                             |
          | ---- 1. Authentication (Trama 2042) ------> |
          | <--- 2. Authentication (Trama 2044) ------- |
          |                                             |
          | ---- 3. Association Request (Trama 2046) -> |
          | <--- 4. Association Response (Trama 2048) - |
          |                                             |
          V                                             V
```

Justificação do fluxo: Como demonstrámos nas múltiplas sequências que analisámos no Wireshark, o processo de associação nas redes IEEE 802.11 exige que a estação complete a fase de autenticação com sucesso antes de
emitir a trama *Association Request*. O processo termina com o AP a enviar a *Association Response*, finalizando a ligação.

=== Pergunta 12
Para a trama de dados da alínea anterior, transcreva os endereços MAC em uso, identificando qual o endereço MAC correspondente ao _host_ sem fios (STA), ao AP e ao _router_ de acesso ao sistema de distribuição.

#figure(
  image("imgs/resposta(Q12&&Q13).jpeg", width: 75%),
  caption: [Análise de direcionalidade da trama de dados baseada nas _flags to DS/from_],
)<fig_to_from_ds>
Direcionalidade e Destino: Analisando a trama 621 (@fig_to_from_ds) e observando o cabeçalho do frame control field, ao abrir as flags, no DS status, temos (To DS: 1 From Ds: 0) que, quanto à direcionalidade, nos indica que a trama está a ser enviada de um dispositivo para o Access Point(AC).

Análise de Endereços: Um pouco abaixo, fora das flags, temos os endereços Destination address (O endereço Mac do dispositivo destinatário) e o Receiver address (o endereço mac do Access Point) ambos iguais (74:9b:e8:f3:9a:46).

Conclusão: Como o destino da trama é o access point, conclui-se que a trama é local à WLan.

=== Pergunta 13
Observa-se que ao longo da transferência de dados são usadas tramas de controlo ACK. Tnte explicar porque razão têm de existir contrariamente ao que acontece numa rede Ethernet.

Endereço da Estação (STA): O endereço MAC do host sem fios (STA) está disponível no STA address (b8:2d:28:7a:9b:68).

Endereço do Ponto de Acesso (AP): O endereço MAC do Access Point é o endereço associado ao BSS Id (74:9b:e8:f3:9a:46).

Endereço do Router: E finalmente, o endereço MAC do router de acesso ao sistema de distribuição também será o mesmo (74:9b:e8:f3:9a:46).

=== Pergunta 14
Redes Ethernet (com fios): Verificámos que nestas redes se utiliza o mecanismo de acesso CSMA/CD (Collision Detection). Como a comunicação é feita por um cabo elétrico, a placa de rede consegue transmitir dados e, ao mesmo tempo, "escutar" a tensão no cabo. Se duas máquinas transmitirem ao mesmo tempo, ocorre uma alteração física no sinal elétrico que ambas detetam imediatamente (detetam a colisão), abortando o envio. Concluímos que, como a rede deteta as falhas em tempo real, não precisa de confirmações constantes para cada pacote.

Redes Wi-Fi (sem fios): Constatámos que se utiliza o mecanismo CSMA/CA (Collision Avoidance). Um rádio Wi-Fi funciona em modo half-duplex, o que significa que não consegue transmitir e receber dados em simultâneo no mesmo canal. Quando um dispositivo está a emitir uma trama para o ar, fica "surdo" ao que se passa à sua volta e não consegue detetar se o seu sinal colidiu com o de outro dispositivo.

A função do ACK: Analisando o funcionamento, percebemos que, como o emissor Wi-Fi não tem forma de detetar colisões por si próprio, necessita de um
mecanismo de confirmação explícita. É por isso que o recetor é obrigado a enviar uma trama de controlo ACK (Acknowledge) sempre que recebe uma trama de
dados com sucesso. Se o emissor original não receber esse ACK num curto espaço de tempo, assume que houve uma colisão (ou muita interferência) e volta a retransmitir a trama original.


=== Pergunta 15
#figure(image("imgs/respostaQ15.png", width: 75%), caption: [Mecanismo de reserva de canal RTS/CTS])<fig:rts_cts>
#figure(image("imgs/respostaQ15(2).png", width: 75%), caption: [])
#figure(image("imgs/respostaQ15(3).png", width: 75%), caption: [])
Sistemas Envolvidos: Ao analisarmos a captura, identificámos que a comunicação ocorre essencialmente entre a estação cliente (STA) `AMPAKTechnol_7a:9b:...` e o ponto de acesso (AP) `HitronTechno_f3:9a:...`.

1. Diagrama de Sequência: Transferência COM opção RTS/CTS (@fig:rts_cts)
Com base nos pacotes 288 a 291 da nossa captura, traçámos o seguinte processo. Este diagrama ilustra de forma clara a "pré-reserva" do canal, que
acontece em 4 passos:
```
    STA (AMPAKTechnol)                                      AP (HitronTechno)
            |                                                       |
            | --- 1. Request-to-send (Pacote 288) ----------------> | (Pedido)
            | <--- 2. Clear-to-send (Pacote 289) ------------------ | (Autorização)
            |                                                       |
            | --- 3. QoS Data (Pacote 290) -----------------------> | (Envio de Dados)
            | <--- 4. Block Ack (Pacote 291) ---------------------- | (Confirmação)
            |                                                       |
            V                                                       V
```
2. Diagrama de Sequência: Transferência SEM opção RTS/CTS
Olhando agora para os pacotes 368 e 369, ilustrámos uma transferência direta mais comum, que ocupa apenas 2 passos. Neste caso não existe uma pré-reserva; a
estação simplesmente verifica se o canal está livre e avança com a transmissão:
```txt
    STA (AMPAKTechnol)                                      AP (HitronTechno)
            |                                                       |
            | --- 1. Null function [No data] (Pacote 368) --------> | (Envio de Dados)
            | <--- 2. Acknowledgement (Pacote 369) ---------------- | (Confirmação)
            |                                                       |
            V                                                       V
```
Nota de análise: Pode parecer um pouco estranho usar um pacote chamado "Null function (No data)" para este exemplo, mas constatámos que o protocolo 802.11 classifica tecnicamente este pacote como uma trama de Dados (Type 2). Por esse motivo, considerámo-lo um exemplo perfeitamente válido para ilustrar uma transferência de
dados sem RTS/CTS que exige uma confirmação imediata.

=== Conclusão Parte 2

Através da análise de tráfego no Wireshark, o nosso grupo consolidou de forma prática os conceitos teóricos do protocolo IEEE 802.11. Aprendemos a identificar parâmetros cruciais da camada física, como a frequência, a norma em uso e a avaliar a qualidade da ligação através da relação Sinal/Ruído (SNR). Observámos também as diferenças entre o scanning passivo (através de tramas Beacon enviadas a baixo débito para garantir maior alcance) e ativo (Probe Request/Response), mapeando na prática o processo estruturado que exige sempre a autenticação prévia de um dispositivo antes de concluir a sua associação à rede.

A nível estrutural e de acesso ao meio, compreendemos a arquitetura complexa de endereçamento do Wi-Fi face à Ethernet e a utilização de flags de direcionalidade para rastrear a informação. Consolidámos a distinção fundamental entre CSMA/CD e CSMA/CA, percebendo que a natureza half-duplex dos rádios impede a deteção nativa de colisões. Esta limitação revelou-nos a importância vital das tramas de confirmação (ACK) e dos mecanismos de pré-reserva de canal (RTS/CTS), ilustrando perfeitamente como o protocolo contorna as adversidades e garante fiabilidade num meio de transmissão partilhado e suscetível a interferências.

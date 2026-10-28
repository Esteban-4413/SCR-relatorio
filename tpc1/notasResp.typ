=== Pergunta 1

    Frequência e Canal: Analisando a secção "802.11 radio information" no Wireshark, identificámos que a rede sem fios está a operar na frequência de 2412 MHz. Verificámos também que esta frequência corresponde ao Canal 1.

=== Pergunta 2

    Versão da Norma: Através do campo "PHY type", constatámos que a versão da norma IEEE 802.11 que está a ser usada na trama capturada é a 802.11b (HR/DSSS).

=== Pergunta 3

    Débito da Trama: Observámos que a trama escolhida foi enviada a um débito (Data rate) de 1.0 Mb/s.

    Justificação do Débito Máximo: Concluímos que este valor não corresponde ao débito máximo a que a interface Wi-Fi pode operar. A norma 802.11b suporta velocidades teóricas até 11 Mb/s. O envio a 1.0 Mb/s justifica-se pelo facto
   de se tratar de uma trama de gestão (um Beacon); estas tramas são transmitidas intencionalmente na taxa base mais baixa para maximizar o alcance da propagação do sinal e garantir que todos os dispositivos
   na vizinhança consigam ouvi-las e descodificá-las com sucesso, independentemente da distância.

=== Pergunta 4

    Força do Sinal e Qualidade: Verificámos na captura que a força do sinal (Signal strength) recebido é de -46 dBm. Além disso, a análise indica um nível de ruído (Noise level) de -93 dBm, o que resulta
   numa relação Sinal/Ruído (Signal/noise ratio) de 47 dB. Tendo em conta o que nos é pedido para verificar face à tabela em Anexo[cite: 16], e perante valores tão favoráveis (um sinal forte de -46 dBm e 
   um excelente SNR de 47 dB), concluímos que a qualidade expectável de receção da trama é classificada como excelente, garantindo uma transmissão muito fiável e sem falhas.

=== Pergunta 5

    Type: Management frame (0)
    Subtype: 8

    Conclusão: A combinação destes dois campos resulta na classificação agregada que observámos na linha destacada a azul, identificando o pacote completo como "Type/Subtype: Beacon frame (0x0008)".   

=== Pergunta 6

    Origem (Source / BSSID): 74:9b:e8:f3:9a:46. Identificado pelo Wireshark como HitronTechno_f3:9a:46, que verificámos corresponder ao endereço MAC do Ponto de Acesso (AP) responsável pela emissão da trama beacon.

    Destino (Destination): ff:ff:ff:ff:ff:ff. Trata-se do endereço físico de Broadcast.

    Conclusão: Concluímos que a trama é gerada por um Ponto de Acesso (AP) e enviada para o endereço de Broadcast, de forma a ser recebida por todas as estações (STA) na sua área de cobertura, servindo o 
  propósito de anunciar a presença da rede e os seus parâmetros.

=== Pergunta 7

    Intervalo previsto: O valor que analisámos (Beacon Interval) no cabeçalho de gestão é de 0.102400 segundos (102,4 milissegundos).

    Justificação: As redes sem fios 802.11 utilizam o mecanismo de contenção e acesso ao meio CSMA/CA. Sabemos que, antes de emitir o beacon, o AP tem de escutar o meio. Se o canal sem fios estiver ocupado por outra 
  transmissão no momento agendado, o AP é forçado a aguardar até que o meio fique livre, o que verificámos introduzir pequenos atrasos na periodicidade destas tramas.

=== Pergunta 8

    Resposta: Através da captura que nos foi fornecida, identificámos o SSID FlyingNet.

    Modo de obtenção (Filtro): Para isolarmos estas tramas, utilizámos o filtro de visualização wlan.fc.type_subtype == 8 no Wireshark, o que nos permitiu selecionar apenas as tramas de gestão do subtipo Beacon.

    Modo de obtenção (Análise): Extraímos o nome específico da rede selecionando um destes pacotes e expandindo a secção IEEE 802.11 Wireless Management > Tagged parameters, localizando depois o campo Tag: SSID parameter set.

=== Pergunta 9

    Tramas Identificadas: Na captura fornecida, conseguimos observar um exemplo claro de probing ativo através da trama 2178 (Probe Request), enviada pela estação de origem AltoBeam_08:32:99, que é 
  imediatamente seguida pelas tramas 2179 e 2180 (Probe Response), enviadas pelo AP TpLink_31:e2:39 como resposta direta. Outro par evidente que encontrámos é o Probe Request da trama 2068 (estação HP_d0:a0:11) e as respetivas
  respostas nas tramas 2070 e 2071.
   
    Probe Request (Endereçamento): Como observámos na coluna "Destination" da captura (ex: pacotes 2068 e 2178), esta trama é endereçada para o MAC de Broadcast (ff:ff:ff:ff:ff:ff).
   
    Probe Request (Propósito): O objetivo é o dispositivo cliente efetuar um scanning ativo, enviando um pedido a todos os dispositivos para descobrir as redes sem fios disponíveis na vizinhança ou procurar um SSID específico.
   
    Probe Response (Endereçamento): Verificámos que a trama (ex: pacotes 2070, 2179 ou o detalhe do pacote 2035) é endereçada em Unicast diretamente para o endereço MAC específico da estação que iniciou o 
  pedido (ex: HP_d0:a0:11, AltoBeam_08:32:99 ou fe:bd:a5:05:6c:84).
  
    Probe Response (Propósito): O objetivo é o Ponto de Acesso (AP) responder de forma direcionada ao dispositivo requerente, confirmando a sua presença na rede e fornecendo-lhe os parâmetros de 
  comunicação (como SSID, canais e taxas suportadas).


=== Pergunta 10

    Sequência de Tramas Identificada: Com base na print que tirámos, conseguimos observar várias sequências completas de associação. Um exemplo claro corresponde ao conjunto das tramas 2042, 2044, 2046 e 2048, trocadas entre a estação `fe:bd:a5:05:6c:84` e o AP `HitronTechno_f3:9a:...` para a rede SSID "FlyingNet".

    Detalhamento da Sequência:

    1. Trama 2042: Authentication (da STA `fe:bd...` para o AP `HitronTechno...`).
    2. Trama 2044: Authentication (do AP `HitronTechno...` para a STA `fe:bd...`).
    3. Trama 2046: Association Request (da STA `fe:bd...` para o AP `HitronTechno...`).
    4. Trama 2048: Association Response (do AP `HitronTechno...` para a STA `fe:bd...`).

    Outros exemplos visíveis: Notámos que a mesma sequência completa também é verificável para a estação `Apple_71:41:a1` (tramas 10365, 10368, 10372, 10376) e para a 
  estação `AzureWaveTec_0f:0e:...` (tramas 10530, 10532, 10536, 10538).



=== Pergunta 11

    Diagrama de Sequência (Exemplo com a STA fe:bd:a5:05:6c:84):


    STA (fe:bd:a5:05:6c:84)                      AP (HitronTechno)
          |                                             |
          | ---- 1. Authentication (Trama 2042) ------> |
          | <--- 2. Authentication (Trama 2044) ------- |
          |                                             |
          | ---- 3. Association Request (Trama 2046) -> |
          | <--- 4. Association Response (Trama 2048) - |
          |                                             |
          V                                             V

    Justificação do fluxo: Como demonstrámos nas múltiplas sequências que analisámos no Wireshark, o processo de associação nas redes IEEE 802.11 exige que a estação complete a fase de autenticação com sucesso antes de 
  emitir a trama *Association Request*. O processo termina com o AP a enviar a *Association Response*, finalizando a ligação.

/* 

REALIZZAZIONE DI UNA QUERY RIFERITA AL DATABASE db_bancario AL FINE DI POTER STRUTTURARE UNA TABELLA CON FEATURE 
DA POTER UTILIZZARE E TRAINARE UN POSSIBILE MODELLO DI ML 

*/


/* Calcolo dell'età di ogni cliente*/
CREATE VIEW banca.eta_cliente as
	select cliente.id_cliente,
    TIMESTAMPDIFF(year, cliente.data_nascita, CURDATE()) as eta
    from banca.cliente;

/* Calcolo numero di transazioni in uscita su tutti i conti*/
CREATE VIEW banca.tot_uscite as
	select conto.id_cliente,conto.id_conto, count(trans_exit.id_conto) as uscite
	from banca.conto
	left join 
	(select transazioni.id_conto, tipo_transazione.segno
		from banca.tipo_transazione left join banca.transazioni
		on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
		where tipo_transazione.segno = '-') trans_exit
	on conto.id_conto = trans_exit.id_conto
	group by 1,2;

/* Calcolo numero di transazioni in entrata su tutti i conti*/
CREATE VIEW banca.tot_entrate as
	select conto.id_cliente,conto.id_conto, count(trans_ent.id_conto) as entrate
		from banca.conto
		left join 
		(select transazioni.id_conto, tipo_transazione.segno
			from banca.tipo_transazione inner join banca.transazioni
			on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
			where tipo_transazione.segno = '+') trans_ent
		on conto.id_conto = trans_ent.id_conto
		group by 1,2;

/* Importo transato in uscita su tutti i conti*/
CREATE VIEW banca.importi_uscite as
	select conto.id_cliente,conto.id_conto, sum(trans_ext.importo) as sum_uscite
			from banca.conto
			left join 
			(select transazioni.id_conto, transazioni.importo, tipo_transazione.segno
				from banca.tipo_transazione inner join banca.transazioni
				on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
				where tipo_transazione.segno = '-') trans_ext
			on conto.id_conto = trans_ext.id_conto
			group by 1,2;

/* Importo transato in entrata su tutti i conti*/
CREATE VIEW banca.importi_entrate as
	select conto.id_cliente,conto.id_conto, sum(trans_ent.importo) as sum_entrate
			from banca.conto
			left join 
			(select transazioni.id_conto, transazioni.importo, tipo_transazione.segno
				from banca.tipo_transazione inner join banca.transazioni
				on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
				where tipo_transazione.segno = '+') trans_ent
			on conto.id_conto = trans_ent.id_conto
			group by 1,2;

/* Numero totale di conti posseduti*/
CREATE VIEW banca.qnt_conti as
select conto.id_cliente, count(id_conto) as tot_conti
from banca.conto
group by 1;


/* Numero di conti posseduti per tipologia (un indicatore per tipo)*/
CREATE VIEW banca.count_conto_base as
select conto.id_cliente, count(desc_tipo_conto) as conto_base
from banca.conto inner join banca.tipo_conto
on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where desc_tipo_conto = 'Conto Base'
group by 1;

CREATE VIEW banca.count_conto_business as
select conto.id_cliente, count(desc_tipo_conto) as conto_business
from banca.conto inner join banca.tipo_conto
on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where desc_tipo_conto = 'Conto Business'
group by 1;

CREATE VIEW banca.count_conto_privati as
select conto.id_cliente, count(desc_tipo_conto) as conto_privati
from banca.conto inner join banca.tipo_conto
on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where desc_tipo_conto = 'Conto Privati'
group by 1;

CREATE VIEW banca.count_conto_famiglie as
select conto.id_cliente, count(desc_tipo_conto) as conto_famiglie
from banca.conto inner join banca.tipo_conto
on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where desc_tipo_conto = 'Conto Famiglie'
group by 1;

/* Numero di transazioni in uscita per tipologia*/
CREATE VIEW banca.uscite_mutuo as
select conto.id_cliente,count(negative.desc_tipo_trans) n_pagamenti_mutuo
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '-') as negative 
on conto.id_conto = negative.id_conto
where negative.desc_tipo_trans = 'Rata mutuo'
group by 1;

CREATE VIEW banca.uscite_acquisti_amz as
select conto.id_cliente,count(negative.desc_tipo_trans) n_acquisti_amz
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '-') as negative 
on conto.id_conto = negative.id_conto
where negative.desc_tipo_trans = 'Acquisto su Amazon'
group by 1;

CREATE VIEW banca.uscite_hotel as
select conto.id_cliente,count(negative.desc_tipo_trans) n_pagamenti_hotel
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '-') as negative 
on conto.id_conto = negative.id_conto
where negative.desc_tipo_trans = 'Hotel'
group by 1;

CREATE VIEW banca.uscite_biglietti_aerei as
select conto.id_cliente,count(negative.desc_tipo_trans) n_pagamenti_aerei
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '-') as negative 
on conto.id_conto = negative.id_conto
where negative.desc_tipo_trans = 'Biglietto aereo'
group by 1;

CREATE VIEW banca.uscite_supermercato as
select conto.id_cliente,count(negative.desc_tipo_trans) n_pagamenti_supermercato
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '-') as negative 
on conto.id_conto = negative.id_conto
where negative.desc_tipo_trans = 'Supermercato'
group by 1;


/* Numero di transazioni in entrata per tipologia*/
CREATE VIEW banca.entrate_stipendio as
select conto.id_cliente,count(positive.desc_tipo_trans) n_acconti_stipendio
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '+') as positive 
on conto.id_conto = positive.id_conto
where positive.desc_tipo_trans = 'Stipendio'
group by 1;

CREATE VIEW banca.entrate_pensione as
select conto.id_cliente,count(positive.desc_tipo_trans) n_acconti_pensione
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '+') as positive 
on conto.id_conto = positive.id_conto
where positive.desc_tipo_trans = 'Pensione'
group by 1;

CREATE VIEW banca.entrate_dividendi as
select conto.id_cliente,count(positive.desc_tipo_trans) n_acconti_dividendi
from banca.conto 
left join (
select id_conto,desc_tipo_trans
from banca.transazioni left join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where segno = '+') as positive 
on conto.id_conto = positive.id_conto
where positive.desc_tipo_trans = 'Dividendi'
group by 1;


/* Importo totale transato in uscita per tipologia di conto*/
CREATE VIEW banca.uscite_base as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_neg.importo) as uscite_conto_base
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '-') trans_neg
on conto.id_conto = trans_neg.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Base'
group by 1,2;

CREATE VIEW banca.uscite_business as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_neg.importo) as uscite_conto_business
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '-') trans_neg
on conto.id_conto = trans_neg.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Business'
group by 1,2;

CREATE VIEW banca.uscite_privati as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_neg.importo) as uscite_conto_privati
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '-') trans_neg
on conto.id_conto = trans_neg.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Privati'
group by 1,2;

CREATE VIEW banca.uscite_famiglie as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_neg.importo) as uscite_conto_famiglie
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '-') trans_neg
on conto.id_conto = trans_neg.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Famiglie'
group by 1,2;


/* Importo totale transato in entrata per tipologia di conto*/
CREATE VIEW banca.entrate_base as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_pos.importo) as entrate_conto_base
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '+') trans_pos
on conto.id_conto = trans_pos.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Base'
group by 1,2;

CREATE VIEW banca.entrate_business as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_pos.importo) as entrate_conto_business
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '+') trans_pos
on conto.id_conto = trans_pos.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Business'
group by 1,2;

CREATE VIEW banca.entrate_privati as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_pos.importo) as entrate_conto_privati
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '+') trans_pos
on conto.id_conto = trans_pos.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Privati'
group by 1,2;

CREATE VIEW banca.entrate_famiglie as
select conto.id_cliente,tipo_conto.desc_tipo_conto, sum(trans_pos.importo) as entrate_conto_famiglie
from banca.conto
left join (
select transazioni.id_conto, transazioni.importo
from banca.transazioni inner join banca.tipo_transazione
on transazioni.id_tipo_trans = tipo_transazione.id_tipo_transazione
where tipo_transazione.segno = '+') trans_pos
on conto.id_conto = trans_pos.id_conto
left join banca.tipo_conto on conto.id_tipo_conto = tipo_conto.id_tipo_conto
where tipo_conto.desc_tipo_conto = 'Conto Famiglie'
group by 1,2;






/* Creazione tabella per utilizzo in modelli ML*/

CREATE TABLE banca.analisi(
id_cliente integer,
eta integer,
uscite integer,
entrate integer,
sum_uscite float,
sum_entrate float,
tot_conti integer,
conto_base_qnt integer,
conto_business_qnt integer,
conto_privati_qnt integer,
conto_famiglie_qnt integer,
acquisti_amazon_qnt integer,
pagamenti_rate_mutuo_qnt integer,
pagamenti_hotel_qnt integer,
pagamenti_biglietti_aerei_qnt integer,
pagamenti_supermercato_qnt integer,
accrediti_stipendio_qnt integer,
accrediti_pensione_qnt integer,
accrediti_dividendi_qnt integer,
tot_uscite_conto_base float,
tot_uscite_conto_business float,
tot_uscite_conto_privati float,
tot_uscite_conto_famiglie float,
tot_entrate_conto_base float,
tot_entrate_conto_business float,
tot_entrate_conto_privati float,
tot_entrate_conto_famiglie float);
INSERT INTO banca.analisi
select eta_cliente.id_cliente,
eta_cliente.eta,
A.uscite,
B.entrate,
C.somma_uscite,
D.somma_entrate,
qnt_conti.tot_conti,
count_conto_base.conto_base,
count_conto_business.conto_business,
count_conto_privati.conto_privati,
count_conto_famiglie.conto_famiglie,
uscite_acquisti_amz.n_acquisti_amz,
uscite_mutuo.n_pagamenti_mutuo,
uscite_hotel.n_pagamenti_hotel,
uscite_biglietti_aerei.n_pagamenti_aerei,
uscite_supermercato.n_pagamenti_supermercato,
entrate_stipendio.n_acconti_stipendio,
entrate_pensione.n_acconti_pensione,
entrate_dividendi.n_acconti_dividendi,
uscite_base.uscite_conto_base,
uscite_business.uscite_conto_business,
uscite_privati.uscite_conto_privati,
uscite_famiglie.uscite_conto_famiglie,
entrate_base.entrate_conto_base,
entrate_business.entrate_conto_business,
entrate_privati.entrate_conto_privati,
entrate_famiglie.entrate_conto_famiglie
from banca.eta_cliente 
left join (select tot_uscite.id_cliente,sum(uscite) as uscite
from banca.tot_uscite group by 1) A on eta_cliente.id_cliente = A.id_cliente
left join (select tot_entrate.id_cliente,sum(entrate) as entrate
from banca.tot_entrate group by 1) B on eta_cliente.id_cliente = B.id_cliente
left join (select importi_uscite.id_cliente,sum(sum_uscite) as somma_uscite
from banca.importi_uscite group by 1) C on eta_cliente.id_cliente = C.id_cliente
left join (select importi_entrate.id_cliente,sum(sum_entrate) as somma_entrate
from banca.importi_entrate group by 1) D on eta_cliente.id_cliente = D.id_cliente
left join banca.qnt_conti on eta_cliente.id_cliente = qnt_conti.id_cliente
left join banca.count_conto_base on eta_cliente.id_cliente = count_conto_base.id_cliente
left join banca.count_conto_business on eta_cliente.id_cliente = count_conto_business.id_cliente
left join banca.count_conto_privati on eta_cliente.id_cliente = count_conto_privati.id_cliente
left join banca.count_conto_famiglie on eta_cliente.id_cliente = count_conto_famiglie.id_cliente
left join banca.uscite_acquisti_amz on eta_cliente.id_cliente = uscite_acquisti_amz.id_cliente
left join banca.uscite_mutuo on eta_cliente.id_cliente = uscite_mutuo.id_cliente
left join banca.uscite_hotel on eta_cliente.id_cliente = uscite_hotel.id_cliente
left join banca.uscite_biglietti_aerei on eta_cliente.id_cliente = uscite_biglietti_aerei.id_cliente
left join banca.uscite_supermercato on eta_cliente.id_cliente = uscite_supermercato.id_cliente
left join banca.entrate_stipendio on eta_cliente.id_cliente = entrate_stipendio.id_cliente
left join banca.entrate_pensione on eta_cliente.id_cliente = entrate_pensione.id_cliente
left join banca.entrate_dividendi on eta_cliente.id_cliente = entrate_dividendi.id_cliente
left join banca.uscite_base on eta_cliente.id_cliente = uscite_base.id_cliente
left join banca.uscite_business on eta_cliente.id_cliente = uscite_business.id_cliente
left join banca.uscite_privati on eta_cliente.id_cliente = uscite_privati.id_cliente
left join banca.uscite_famiglie on eta_cliente.id_cliente = uscite_famiglie.id_cliente
left join banca.entrate_base on eta_cliente.id_cliente = entrate_base.id_cliente
left join banca.entrate_business on eta_cliente.id_cliente = entrate_business.id_cliente
left join banca.entrate_privati on eta_cliente.id_cliente = entrate_privati.id_cliente
left join banca.entrate_famiglie on eta_cliente.id_cliente = entrate_famiglie.id_cliente
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;

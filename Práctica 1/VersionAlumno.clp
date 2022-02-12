;;;
;;; Hechos estaticos;
;;;

(deffacts Habitaciones
	(habitacion salon)    
	(habitacion cocina)
	(habitacion pasillo)
	(habitacion comedor)
	(habitacion habitacion1)
	(habitacion habitacion2)
	(habitacion habitacion3)
	(habitacion despensa)
	(habitacion lavadero)
	(habitacion aseo1)
	(habitacion aseo2)
	(habitacion entrada)
	(habitacion despacho)
)

(deffacts Puertas
	(puerta salon pasillo)
	(puerta cocina pasillo)
)

(deffacts Ventanas
	(ventana salon)
	(ventana lavadero)
	(ventana despacho)
	(ventana aseo1)
	(ventana aseo2)
	(ventana habitacion1)
	(ventana habitacion2)
	(ventana habitacion3)	
)


(deffacts Estados
	(estado_habitacion salon inactiva)
	(estado_habitacion cocina inactiva)
	(estado_habitacion pasillo inactiva)
	(estado_habitacion comedor inactiva)
	(estado_habitacion habitacion1 inactiva)
	(estado_habitacion habitacion2 inactiva)
	(estado_habitacion habitacion3 inactiva)
	(estado_habitacion despensa inactiva)
	(estado_habitacion lavadero inactiva)
	(estado_habitacion aseo1 inactiva)
	(estado_habitacion aseo2 inactiva)
	(estado_habitacion entrada inactiva)
	(estado_habitacion despacho inactiva)
)

(deffacts Iluminacion
	(interruptor salon off)
	(interruptor cocina off)
	(interruptor pasillo off)
	(interruptor comedor off)
	(interruptor habitacion1 off)
	(interruptor habitacion2 off)
	(interruptor habitacion3 off)
	(interruptor despensa off)
	(interruptor lavadero off)
	(interruptor aseo1 off)
	(interruptor aseo2 off)
	(interruptor entrada off)
	(interruptor despacho off)
)

;;; Definición de constantes globales
(deffacts Constantes
	(luz salon 300)
	(luz cocina 200)
	(luz pasillo 200)
	(luz comedor 300)
	(luz habitacion1 150)
	(luz habitacion2 150)
	(luz habitacion3 150)
	(luz despensa 200)
	(luz lavadero 200)
	(luz aseo1 200)
	(luz aseo2 200)
	(luz entrada 200)
	(luz despacho 500)
)


;;;
;;; Reglas primeras deducciones mínimas;
;;;

;;; Existe una puerta o paso entre esas dos habitaciones

(defrule PosiblePasar
	(or (puerta ?h1 ?h2) (paso ?h1 ?h2))
	=>
	(assert (posible_pasar ?h1 ?h2))
)

;;; Existe un único paso a la habitación h2, la h1

(defrule NecesarioPasar
	(habitacion ?h1)
	(or (puerta ?h1 ?h2) (puerta ?h2 ?h1) (paso ?h1 ?h2) (paso ?h2 ?h1) )
	(not (exists(or (puerta ?h1 ?h3 & ~?h2) (puerta ?h3 & ~?h2 ?h1) (paso ?h1 ?h3 & ~?h2) (paso ?h3 & ~?h2 ?h1))))
	=>
	(assert (necesario_pasar ?h2 ?h1))
)

;;; La habitación es interior si no tiene ventanas

(defrule HabitacionInterior
	(habitacion ?h) (not (ventana ?h))
	=>
	(assert (habitacion_interior ?h))
)

;;;
;;; Registro de datos de los sensores;
;;; Registro de datos proporcionados;
;;;

;;; Registra un valor como valor_registrado y lo borra de la lista de hechos

(defrule Registrar
	?Borra <- (valor ?tipo ?habitacion ?v)
	(HoraActualizada ?t1)
	=>
	(assert (valor_registrado ?t1 ?tipo ?habitacion ?v))
	(retract ?Borra)
)

;; Define el último registro por habitación y tipo de sensor

(defrule UltimoRegistro
	(valor_registrado ?t1 ?tipo ?h ?v)
	=>
	(assert (ultimo_registro ?tipo ?h ?t1))
)

;;; Borra el último registro más antiguo

(defrule BorrarUltimoRegistro
	?Borra <- (ultimo_registro ?tipo ?h ?t1)
	(exists (ultimo_registro ?tipo ?h ?t2)
		(test (< ?t1 ?t2)))
	=>
	(retract ?Borra)
)

;;; Define la última activación de un sensor de movimiento

(defrule UltimoActivacionMov
	(valor_registrado ?t1 movimiento ?h on)
	(or (exists (ultima_activacion movimiento ?h ?t2)
		(ultima_desactivacion movimiento ?h ?t3)
		(test (< ?t2 ?t3)))
		(not (exists (ultima_activacion ? ?h ?))))
	=>
	(assert (ultima_activacion movimiento ?h ?t1))
)

;;; Borro la última activación más antigua

(defrule BorrarUltimaActivacionMov
	?Borra <-(ultima_activacion movimiento ?h ?t1)
	(exists (ultima_activacion movimiento ?h ?t2)
		(test (< ?t1 ?t2)))
	=>
	(retract ?Borra)
)

;;; Define la última desactivación de un sensor de movimiento

(defrule UltimaDesactivacionMov
	(valor_registrado ?t1 movimiento ?h off)
	(or (exists (ultima_desactivacion movimiento ?h ?t2)
		(ultima_activacion movimiento ?h ?t3)
		(test (< ?t2 ?t3)))
		(not (exists (ultima_desactivacion ? ?h ?))))
	=>
	(assert (ultima_desactivacion movimiento ?h ?t1))
)

;;; Borro la última desactivación más antigua

(defrule BorrarUltimaDesactivacionMov
	?Borra <-(ultima_desactivacion movimiento ?h ?t1)
	(exists (ultima_desactivacion movimiento ?h ?t2)
		(test (< ?t1 ?t2)))
	=>
	(retract ?Borra)
)

;;;
;;; Informe de datos recibidos;
;;;

;;; Genera un informe auxiliar incluyendo todos los valores registrados

(defrule InformeAuxiliar
	(informe ?h)
	(valor_registrado ?t1 ?tipo ?h ?v)
	=>
	(assert (informeAux ?t1 ?tipo ?h ?v))	
)

;;; Imprime el informe en orden ascendente de tiempo

(defrule MuestraBorraInforme
	(declare (salience -1)) 
	?Borra <- (informeAux ?t1 ?tipo1 ?h ?v)
	(not (exists (informeAux ?t2 ? ? ?)
		(test(< ?t2 ?t1))))
	=>
	(printout t crlf ?t1 " : " ?h "  Sensor de " ?tipo1 " valor " ?v crlf)
	(retract ?Borra)
)
	
;;; Borra el hecho informe de la agenda

(defrule BorraInforme
	(declare (salience -2)) 
	?Borra <- (informe ?h)
	=>
	(retract ?Borra)
)

;;;
;;; Manejo inteligente de luces;
;;; Versión con conocimiento propio;
;;;

;;; Enciende el interruptor de la habitación si registra estadoluz on

(defrule EnciendeInterruptor
	(ultimo_registro estadoluz ?h ?t1)
	(valor_registrado ?t1 estadoluz ?h on)
	?Borra <- (interruptor ?h off)
	=>
	(assert (interruptor ?h on))
	(retract ?Borra)
)

;;; Apaga el interruptor de la habitación si registra estadoluz off

(defrule ApagaInterruptor
	(ultimo_registro estadoluz ?h ?t1)
	(valor_registrado ?t1 estadoluz ?h off)
	?Borra <- (interruptor ?h on)
	=>
	(assert (interruptor ?h off))
	(retract ?Borra)
)	

;;; Si se registra movimiento en una habitación y estaba 
;;; en estado inactiva, pasa a estar activa

(defrule HabitacionActiva
	(Manejo_inteligente_luces ?h)
	?Borra <- (estado_habitacion ?h inactiva)
	(ultimo_registro movimiento ?h ?t1)
	(valor_registrado ?t1 movimiento ?h on)
	=>
	(assert (estado_habitacion ?h activa))
	(retract ?Borra)
)

;;; Si una habitación estaba activa y se detecta un
;;; sensor de movimiento off, pasa a inactiva

(defrule HabitacionInactiva
	(Manejo_inteligente_luces ?h)
	?Borra <- (estado_habitacion ?h activa)
	(ultimo_registro movimiento ?h ?t1)
	(valor_registrado ?t1 movimiento ?h off)
	=>
	(assert (estado_habitacion ?h inactiva))
	(retract ?Borra)
)

;;;
;;; 1. Si una habitación tiene una luz encendida y hay más de 500 lux la apago.
;;;

(defrule Regla1
	(Manejo_inteligente_luces ?h)
	(interruptor ?h on)
	(ultimo_registro luminosidad ?h ?t2)
	(valor_registrado ?t2 luminosidad ?h ?v)
		(test (< 500 ?v))
	=>
	(assert (accion pulsador_luz ?h apagar))
)

;;;
;;; 2. Si una habitación está activa y son las 9 de la noche, la enciendo.
;;;

(defrule Regla2
	(Manejo_inteligente_luces ?h)
	(estado_habitacion ?h activa)
	(HoraActualizada ?)
	(interruptor ?h off)
		(test (> ?*hora* 20))
	=>
	(assert (accion pulsador_luz ?h encender))
)

;;;
;;; 3. Si una habitación está inactiva y tiene la luz encendida, la apago.
;;;

(defrule Regla3
	(Manejo_inteligente_luces ?h)
	(estado_habitacion ?h inactiva)
	(interruptor ?h on)
	=>
	(assert (accion pulsador_luz ?h apagar))
)	

;;;
;;; 4. Si una habitación está activa y tiene menos de 100 lux la enciendo.
;;;

(defrule Regla4
	(Manejo_inteligente_luces ?h)
	(estado_habitacion ?h activa)
	(interruptor ?h off)
	(ultimo_registro luminosidad ?h ?t1)
	(valor_registrado ?t1 luminosidad ?h ?v)
		(test (> 100 ?v))						; Si el valor de luminosidad es menor que 100
	=>
	(assert (accion pulsador_luz ?h encender))
)
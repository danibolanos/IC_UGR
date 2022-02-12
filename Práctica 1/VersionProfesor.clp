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
;;; Versión con conocimiento profesor;
;;;

;;; Crea un hecho interruptor a on y borra el antiguo a off

(defrule EnciendeInterruptor
	(ultimo_registro estadoluz ?h ?t1)
	(valor_registrado ?t1 estadoluz ?h on)
	?Borra <- (interruptor ?h off)
	=>
	(assert (interruptor ?h on))
	(retract ?Borra)
)

;;; Crea un hecho interruptor a off y borra el antiguo a on

(defrule ApagaInterruptor
	(ultimo_registro estadoluz ?h ?t1)
	(valor_registrado ?t1 estadoluz ?h off)
	?Borra <- (interruptor ?h on)
	=>
	(assert (interruptor ?h off))
	(retract ?Borra)
)	

;;; Si se registra movimiento en una habitación y estaba 
;;; en estado inactiva o parece_inactiva, pasa a estar activa

(defrule HabitacionActiva
	(Manejo_inteligente_luces ?h)
	?Borra <- (estado_habitacion ?h parece_inactiva|inactiva)
	(ultimo_registro movimiento ?h ?t1)
	(valor_registrado ?t1 movimiento ?h on)
	=>
	(assert (estado_habitacion ?h activa))
	(retract ?Borra)
)

;;; Si no se detecta movimiento en la habitación y está activa
;;; pero no se detecta el paso reciente, la habitación queda activa.
;;; En caso de que se detecte movimiento, la habitación quedará en parece_inactiva
;;; y se apagará en 3 seg si el paso es reciente o en 10 seg en otro caso.

(defrule HabitacionPareceInactiva
	(Manejo_inteligente_luces ?h1)
	?Borra <-(estado_habitacion ?h1 activa)
	(ultimo_registro movimiento ?h1 ?t1)
	(valor_registrado ?t1 movimiento ?h1 off)
	(exists (or (posible_pasar ?h1 ?h2) (posible_pasar ?h2 ?h1))
		(valor_registrado ?t2 movimiento ?h2 on)
		(ultimo_registro movimiento ?h2 ?t2))
	=>
	(assert (estado_habitacion ?h1 parece_inactiva))
	(retract ?Borra)
)

;;;
;;; 1. Si una habitación no está vacía y hay poca luz la enciendo.
;;;

(defrule HabitacionActivaPocaLuz
	(Manejo_inteligente_luces ?h)
	(estado_habitacion ?h activa)
	(interruptor ?h off)
	(luz ?h ?l)
	(ultimo_registro luminosidad ?h ?t1)
	(valor_registrado ?t1 luminosidad ?h ?v)
		(test (> ?l ?v))					; Si el valor de luminosidad es menor que la necesaria
	=>
	(assert (accion pulsador_luz ?h encender))
)

;;;
;;; 2. Si una habitación está vacía y tiene la luz encendida, la apago.
;;; Si la habitación parece inactiva durante 10 segundos, pasa a inactiva.
;;;

(defrule HabitacionInactiva10seg
	(Manejo_inteligente_luces ?h)
	?Borra <- (estado_habitacion ?h parece_inactiva)
	(HoraActualizada ?t1)
	(ultima_desactivacion movimiento ?h ?t2)
		(test (> (- ?t1 ?t2) 10))				; Si la diferencia de tiempos es mayor a 10 seg
	=>
	(assert (estado_habitacion ?h inactiva))
	(retract ?Borra)
)

;;; Se detecta un paso reciente (3 segundos) a habitación colindante. 
;;; Entonces la habitación pasa a inactiva.

(defrule PasoReciente3seg
	(Manejo_inteligente_luces ?h1)
	?Borra <-(estado_habitacion ?h1 parece_inactiva)
	(exists (or (posible_pasar ?h1 ?h2) (posible_pasar ?h2 ?h1)))
	(HoraActualizada ?t1)
	(ultima_activacion movimiento ?h2 ?t2)
		(test (< (- ?t1 ?t2) 3))				; Si la diferencia de tiempos es menor a 3 seg
	=>
	(assert (estado_habitacion ?h1 inactiva))
	(retract ?Borra)
)

;;;
;;; 3. Si la luz está encendida y hay mucha luminosidad, apago la luz. 
;;; Mucha es el doble de la necesaria.
;;;

(defrule ApagoLuzDobleLuminosidad
	(Manejo_inteligente_luces ?h)
	(interruptor ?h on)
	(luz ?h ?l)
	(ultimo_registro luminosidad ?h ?t1)
	(valor_registrado ?t1 luminosidad ?h ?v)
		(test (< (* ?l 2) ?v))					; Si el valor de luminosidad es mayor que el doble necesitada
	=>
	(assert (accion pulsador_luz ?h apagar))
)

;;; Si la habitación está inactiva, apago la luz.

(defrule ApagoLuzHabitacionInactiva
	(Manejo_inteligente_luces ?h)
	(estado_habitacion ?h inactiva)
	(interruptor ?h on)
	=>
	(assert (accion pulsador_luz ?h apagar))
)	
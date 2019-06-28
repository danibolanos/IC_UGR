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
	(puerta entrada cocina)
	(puerta entrada comedor)
	(puerta cocina despensa)
	(puerta cocina lavadero)
	(puerta comedor pasillo)
	(puerta pasillo despacho)
	(puerta pasillo aseo1)
	(puerta pasillo habitacion1)
	(puerta pasillo habitacion2)
	(puerta pasillo habitacion3)
	(puerta habitacion3 aseo2)
)

(deffacts Pasos
	(paso salon comedor)
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
;;; Versión inicial;
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

;;;
;;; SBC para alertar de problemas de personas mayores que viven solas;
;;; Versión final;
;;;

;;; Hechos estáticos para casa inteligente

(deffacts Estados
	(estado dia)
	(asistente off)
	(NumeroHechos VisitaAseo 0)
	(NumeroHechos ActividadMedia 0)
	(HoraInicial 0)
)

(deffacts Semana
  (dia lunes)
  ;(dia martes)
  ;(dia miercoles)
  ;(dia jueves)
  ;(dia viernes)
  ;(dia sabado)
  ;(dia domingo)
)

;;; Inicializa el contador de tiempo de acceso a aseo

(defrule HoraInicialAseo
	(declare (salience 1000))
	(HoraActualizada ?t1)
	?Borra<-(HoraInicial 0)
	=>
	(assert (HoraInicial ?t1))
	(retract ?Borra)
)

;;; Creo una casa inteligente

(defrule CasaInteligente
	(habitacion ?h)
	=>
	(assert (Manejo_inteligente_luces ?h))
	(assert (Manejo_inteligente_casa))
)

;;; Controlo el paso del día a la noche y viceversa
;;; Supondremos que amanece a las 6:00 y anochece a las 19:00

(defrule DiaNoche
	?Borra <- (estado dia)
	(hora_actual ?t1)
	(test (> ?t1 19))
	=>
	(assert (estado noche))
	(retract ?Borra)
)

(defrule NocheDia
	?Borra <- (estado noche)
	(hora_actual ?t1)
	(test (> ?t1 6))
	=>
	(assert (estado dia))
	(retract ?Borra)
)

;;; Controlo los días cuando trabaja el asistente
;;; De lunes a sábados. De 10h a 14h.

(defrule TrabajoAsistente
	(dia ?d)
	(hora_actual ?t1)
	?Borra <- (asistente off)
	(test (neq ?d domingo))
	(test (> ?t1 9))
	(test (< ?t1 15))
	=>
	(assert (asistente deberia_estar))
	(retract ?Borra)
)

;;;
;;; 1. La persona ha salido de casa.
;;;	Si la entrada parece_inactiva, es decir, ha registrado movimiento en ella
;;; pero aún no puede saber si ha salido pero no se registra movimiento
;;; en ninguna habitación colindante, supondremos que la persona ha salido de casa.
;;;

(defrule PersonaSaleCasa
	(Manejo_inteligente_casa)
	(estado_habitacion entrada parece_inactiva)
	(or (posible_pasar entrada ?h2) (posible_pasar ?h2 entrada))
	(estado_habitacion ?h2 inactiva)
	=>
	(printout t crlf "La persona ha salido de casa." crlf)
)

;;;
;;; 2. Siendo de día la persona no se ha movido por casa en las últimas 3 horas.
;;; Siendo de día:
;;;	Si la diferencia de la última activación de movimiento en la casa con la hora actual
;;; es mayor a 3h = 10800seg, la persona no se ha movido en ese tiempo
;;;

(defrule DiaCasa3Horas
	(Manejo_inteligente_casa)
	(estado dia)
	(HoraActualizada ?t1)
	(not (exists (ultima_activacion movimiento ?h ?t2)
		(test (< (- ?t1 ?t2) 10800))))
	=>
	(printout t crlf "La persona no se ha movido en las ultimas 3 h por el dia." crlf)
)

;;;
;;; 3. La persona se ha levantado durante más de 15 minutos por la noche.
;;; Siendo de noche:
;;;	Si la diferencia de la última activación de movimiento en la habitación 1 con la hora actual
;;; es mayor a 15min = 900seg y la habitación 1 está inactiva. Lleva fuera de su habitación más de 15 min.
;;;

(defrule Noche15Min
	(Manejo_inteligente_casa)
	(estado noche)
	(HoraActualizada ?t1)
	(estado_habitacion habitacion1 inactiva)
	(exists (ultima_activacion movimiento habitacion1 ?t2)
		(test (< (- ?t1 ?t2) 900)))
	=>
	(printout t crlf "La persona se ha levantado de su cama mas de 15 min por la noche." crlf)
)

;;;
;;; 4. Estando sola, la persona lleva más 20 minutos en el baño.
;;; Haremos esta regla útil para cualquiera de los dos baños existentes.
;;; El asistente no está, el aseo está activo o parece_inactivo y el
;;; último movimiento de la habitación obligatoria de acceso al baño, fue hace 20 min = 1200 seg.
;;;

(defrule Sola20MinAseo1
	(Manejo_inteligente_casa)
	(asistente off)
	(or (necesario_pasar aseo1 ?h1) (necesario_pasar ?h1 aseo1))
	(or (estado_habitacion aseo1 parece_inactiva) (estado_habitacion aseo1 activa))
	(HoraActualizada ?t1)
	(exists (ultima_activacion movimiento ?h1 ?t2)
		(test (< (- ?t1 ?t2) 1200)))
	=>
	(printout t crlf "La persona lleva sola mas de 20 min en el aseo1." crlf)
)

(defrule Sola20MinAseo2
	(Manejo_inteligente_casa)
	(asistente off)
	(or (necesario_pasar aseo2 ?h1) (necesario_pasar ?h1 aseo2))
	(or (estado_habitacion aseo2 parece_inactiva) (estado_habitacion aseo2 activa))
	(HoraActualizada ?t1)
	(exists (ultima_activacion movimiento ?h1 ?t2)
		(test (< (- ?t1 ?t2) 1200)))
	=>
	(printout t crlf "La persona lleva sola mas de 20 min en el aseo2." crlf)
)

;;;
;;; 5. La persona no ha ido al baño en las últimas 12 horas.
;;;	La última activación de movimiento en alguno de los dos aseos.
;;;	Fue hace 12h = 43000 seg.
;;;

(defrule NoAseo12Horas
	(Manejo_inteligente_casa)
	(HoraActualizada ?t1)
	(exists (ultima_activacion movimiento aseo1 ?t2) (ultima_activacion movimiento aseo2 ?t2)
		(test (< (- ?t1 ?t2) 43200)))
	=>
	(printout t crlf "La persona no ha ido a ningun aseo en 12 h." crlf)
)

;;;
;;; 6. La persona ha ido al baño varias veces en las últimas 3 horas.
;;; Usando el contador de hechos de los ejercicios propuestos.
;;; Contamos el número de veces que se detecta activo un aseo.
;;; Si el número supera a 2 en menos de 3 horas, se informa de ello y
;;; se vuelven a poner a 0 los contadores de visitas al baño.
;;;

(defrule incrementaNumeroHechos
	?Borra<-(VisitaAseo $?)
	=>
	(assert(sumarHechos VisitaAseo))
	(retract ?Borra)
)

(defrule contador
	?Borra <- (sumarHechos VisitaAseo)
	?Elimina <- (NumeroHechos VisitaAseo ?n)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(bind ?t (+ ?n 1))
	(assert (NumeroHechos VisitaAseo ?t))
)

(defrule EntradaAseo1
	(valor_registrado ?t1 movimiento aseo1 ?v)
	=>
	(assert (VisitaAseo ?t1))
)

(defrule EntradaAseo2
	(valor_registrado ?t1 movimiento aseo2 ?v)
	=>
	(assert (VisitaAseo ?t1))
)

(defrule VisitaAseoVariasVeces3Horas
	(Manejo_inteligente_casa)
	?Elimina<-(NumeroHechos VisitaAseo ?n)
	(test (> ?n 1))
	?Borra<-(HoraInicial ?t0)
	(HoraActualizada ?t1)
		(test (< (- ?t0 ?t1) 10800))
	=>
	(printout t crlf "La persona ha ido al aseo " ?n " veces en menos de 3 h"  crlf)
	(retract ?Borra)
	(retract ?Elimina)
	(assert (NumeroHechos VisitaAseo 0))
	(assert (HoraInicial 0))
)

;;; Si no ocurre, no se informa pero los contadores vuelven a cero.

(defrule NoVisitaAseoVariasVeces3Horas
	(Manejo_inteligente_casa)
	?Elimina<-(NumeroHechos VisitaAseo ?n)
	(test (< ?n 2))
	?Borra<-(HoraInicial ?t0)
	(HoraActualizada ?t1)
		(test (< (- ?t0 ?t1) 10800))
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(assert (NumeroHechos VisitaAseo 0))
	(assert (HoraInicial 0))
)

;;;
;;; 7. La asistenta tendría que haber llegado, pero no lo ha hecho.
;;;	Si no existe una última activación de movimiento en la entrada
;;; con un tiempo inferior al actual y  debería estar trabajando
;;; el asistente no ha llegado, en caso contrario, sí.
;;;

(defrule AsistenteNoLlega
	(asistente deberia_estar)
	(HoraActualizada ?t)
	(not (exists (ultima_activacion movimiento entrada ?t1)
		(test (< ?t1 ?t))))
	=>
	(printout t crlf "El asistente no ha llegado a su hora."  crlf)
	(assert (asistente off))
)

(defrule AsistenteLlega
	(asistente deberia_estar|off)
	(HoraActualizada ?t)
	(ultima_activacion movimiento entrada ?t1)
		(test (< ?t1 ?t))
	=>
	(assert (asistente on))
)

;;;
;;; 8. Es tarde y la persona no se ha acostado.
;;; Definiremos tarde para la persona mayor las 23:00.
;;;	Son las 23:00 y existe alguna habitación distinta al
;;; dormitorio (donde duerme la persona mayor) con actividad
;;; o que parece que tiene actividad.
;;;

(defrule PersonaNoAcostada
	(hora_actual ?t)
	(test (> ?t 22))
	(exists (estado_habitacion ?h activa|parece_inactiva)
		(test (neq ?h habitacion1)))
	=>
	(printout t crlf "La persona no está en su habitacion tarde."  crlf)
)

;;;
;;; 9. La persona tiene menos actividad de lo normal.
;;; 10. La persona hace desplazamientos por la casa que no hace
;;; normalmente en esa franja horaria (mañana, tarde o noche).
;;;
;;;	Vamos a utilizar un contador de hechos para la actividad por el día
;;; los domingos que es cuando no trabaja el asistente.
;;;	Incrementaremos cada vez que se detecte movimiento en una
;;; habitación y consideraremos como actividad media normal
;;; una media de 40 movimientos por la casa al día.
;;;	Si el número esos movimientos es menor, se informará.
;;;

(defrule incrementaNumeroHechos2
	?Borra<-(ActividadMedia $?)
	=>
	(assert(sumarHechos ActividadMedia))
	(retract ?Borra)
)

(defrule contador2
	?Borra <- (sumarHechos ActividadMedia)
	?Elimina <- (NumeroHechos ActividadMedia ?n)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(bind ?t (+ ?n 1))
	(assert (NumeroHechos ActividadMedia ?t))
)

(defrule EntradaHabitacion
	(valor_registrado ?t1 movimiento ?h ?v)
	=>
	(assert (ActividadMedia ?t1))
)

(defrule ActividadMediaIrregular
	(Manejo_inteligente_casa)
	(dia domingo)
	(NumeroHechos ActividadMedia ?n)
	(test (< ?n 41))
	=>
	(printout t crlf "La persona ha hecho un numero " (- 40 ?n) " menor de movimientos de lo normal."  crlf)
)

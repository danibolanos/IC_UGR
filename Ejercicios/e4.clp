;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 4: Bucle de Espera.

(deffacts contadorInicial
	(Contador 0)
	(TiempoInicial (time))
)

(defrule ultimaRegla
	(declare (salience -10000))
	?Borra <- (Contador ?n)
	(TiempoInicial ?t)
	=>
	(assert(Contador (- (time) ?t)))
	(retract ?Borra)
)

(defrule contador
	(declare (salience -50))
	?Elimina <- (TiempoInicial ?t)
	?Borra <- (Contador ?n)
		(test (> ?n 60))
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(printout t "Estoy esperando nueva informacion" crlf)
	(assert(Contador 0))
	(assert (TiempoInicial (time)))
)
	
;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 1: Contar hechos de un tipo.

;;; a) Mediante contador.

(deffacts ejemplos
	(XXX Salon)
	(XXX Cocina)
	(NumeroHechos XXX 0)
)

(defrule incrementaNumeroHechos
	(XXX $?)
	=>
	(assert(sumarHechos XXX))
)

(defrule contador
	?Borra <- (sumarHechos XXX)
	?Elimina <- (NumeroHechos XXX ?n)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(bind ?t (+ ?n 1)) 	
	(assert (NumeroHechos XXX ?t))
)

(defrule eliminarHecho
	?Borra <- (eliminar XXX ?v)
	?Borrar <- (XXX ?v)
	?Elimina <- (NumeroHechos XXX ?n)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(retract ?Borrar)
	(bind ?t (- ?n 1)) 	
	(assert (NumeroHechos XXX ?t))
)
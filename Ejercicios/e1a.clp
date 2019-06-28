;;;
;;; Ejercicios CLIPS 2018
;;; Alumno: Daniel Bolaños Martínez
;;;

;;; Ejercicio 1: Contar hechos de un tipo.

;;; a) Bajo demanda.

(deffacts ejemplos
	(XXX Salon)
	(XXX Cocina)
)

;;; Regla cuando no hay hechos
(defrule iniciarContadorSinHechosPrevios
	?Borra <- (ContarHechos XXX)
	(not (exists (NumeroHechos XXX ?v)))
	=>
	(retract ?Borra)
	(assert (NumeroHechos XXX 0))
	(assert (Iniciar))
)

;;; Regla cuando existen hechos
(defrule iniciarContadorConHechosPrevios
	?Borra <- (ContarHechos XXX)
	?Elimina <- (NumeroHechos XXX ?v)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(assert (NumeroHechos XXX 0))
	(assert (Iniciar))
)

(defrule incrementaNumeroHechos
	(Iniciar)
	(XXX $?)
	=>
	(assert (incrementaContador XXX))
)

(defrule contador
	?Borra <- (incrementaContador XXX)
	?Elimina <- (NumeroHechos XXX ?n)
	=>
	(retract ?Borra)
	(retract ?Elimina)
	(bind ?t (+ ?n 1)) 	
	(assert (NumeroHechos XXX ?t))
)

(defrule eliminarInicializador
	?Borra <- (Iniciar)
	=>
	(retract ?Borra)
)

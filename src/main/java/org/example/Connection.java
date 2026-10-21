package org.example;

import alice.tuprolog.Prolog;
import alice.tuprolog.SolveInfo;
import alice.tuprolog.Struct;
import alice.tuprolog.Term;
import alice.tuprolog.Theory;

import java.io.InputStream;
import java.util.Set;

public class Connection {
    private static final Set<String> OPERADORES = Set.of("+", "-", "*", "/", "^");

    private final Prolog engine = new Prolog();

    public Connection() throws Exception {
        try (InputStream in = getClass().getResourceAsStream("/calculo.pl")) {
            if (in == null) throw new IllegalStateException("No se encontró calculo.pl");
            engine.setTheory(new Theory(in));
        }
    }

    public String consultar(String predicado, String expresion) throws Exception {
        SolveInfo info = engine.solve(predicado + "(x, " + expresion + ", R).");
        return info.isSuccess() ? formatear(info.getTerm("R"))
                : "Sin solución para esa expresión";
    }

    private String formatear(Term termino) {
        Term t = termino.getTerm();
        if (t instanceof Struct s) {
            String nombre = s.getName();
            if (s.getArity() == 2 && OPERADORES.contains(nombre)) {
                String izq = formatear(s.getArg(0));
                String der = formatear(s.getArg(1));
                if (nombre.equals("+") || nombre.equals("-")) {
                    return izq + " " + nombre + " " + der;
                }
                return izq + nombre + der;
            }
            if (s.getArity() == 1 && nombre.equals("-")) {
                return "-" + formatear(s.getArg(0));
            }
        }
        return t.toString();
    }
}

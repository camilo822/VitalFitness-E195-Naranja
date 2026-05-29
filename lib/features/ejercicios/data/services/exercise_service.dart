// ─── Modelo ───────────────────────────────────────────────────────────────────
class EjercicioData {
  final String id;
  final String nombre;
  final String musculo;
  final String musculos;
  final String nivel;
  final String equipo;
  final String imagenUrl;
  final List<String> instrucciones;
  final List<String> musculosSecundarios;

  const EjercicioData({
    required this.id,
    required this.nombre,
    required this.musculo,
    required this.musculos,
    required this.nivel,
    required this.equipo,
    required this.imagenUrl,
    required this.instrucciones,
    required this.musculosSecundarios,
  });

  static int colorForBodyPart(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'pecho':   return 0xFFCCFF00;
      case 'espalda': return 0xFF8A2BE2;
      case 'piernas': return 0xFF00D4FF;
      case 'hombros': return 0xFFFF9500;
      case 'brazos':  return 0xFF00E676;
      case 'abdomen': return 0xFFFF3B30;
      default:        return 0xFFCCFF00;
    }
  }
}

// ─── Servicio ─────────────────────────────────────────────────────────────────
class ExerciseService {
  static final _db = <String, List<EjercicioData>>{

    // ══════════════════════════════════════════════════════════════════════════
    // PECHO
    // ══════════════════════════════════════════════════════════════════════════
    'pecho': [
      EjercicioData(
        id: 'bench_press',
        nombre: 'Press de Banca',
        musculo: 'Pectorales',
        musculos: 'Pecho',
        nivel: 'INTERMEDIO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/press_banca.png',
        instrucciones: [
          'Acuéstate en el banco con los pies apoyados en el suelo.',
          'Agarra la barra con las manos separadas al ancho de los hombros.',
          'Baja la barra lentamente hacia el pecho.',
          'Empuja la barra hacia arriba extendiendo los brazos completamente.',
          'Mantén los codos a 45 grados del cuerpo durante el movimiento.',
        ],
        musculosSecundarios: ['Tríceps', 'Hombros anteriores'],
      ),
      EjercicioData(
        id: 'incline_press',
        nombre: 'Press Inclinado con Mancuernas',
        musculo: 'Pectorales superiores',
        musculos: 'Pecho',
        nivel: 'INTERMEDIO',
        equipo: 'Mancuernas',
        imagenUrl: 'assets/images/press_inclinado-con-mancuernas.png',
        instrucciones: [
          'Ajusta el banco a 30-45 grados de inclinación.',
          'Sostén las mancuernas a la altura del pecho con los codos doblados.',
          'Empuja las mancuernas hacia arriba hasta extender los brazos.',
          'Baja lentamente controlando el movimiento.',
        ],
        musculosSecundarios: ['Tríceps', 'Deltoides anterior'],
      ),
      EjercicioData(
        id: 'push_up',
        nombre: 'Flexiones de Pecho',
        musculo: 'Pectorales',
        musculos: 'Pecho',
        nivel: 'PRINCIPIANTE',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/flexiones_de_pecho.png',
        instrucciones: [
          'Colócate en posición de plancha con las manos separadas al ancho de los hombros.',
          'Mantén el cuerpo recto desde la cabeza hasta los talones.',
          'Baja el pecho hacia el suelo doblando los codos.',
          'Empuja hacia arriba hasta extender los brazos.',
          'Repite manteniendo el core activo en todo momento.',
        ],
        musculosSecundarios: ['Tríceps', 'Core'],
      ),
      EjercicioData(
        id: 'chest_fly',
        nombre: 'Aperturas con Mancuernas',
        musculo: 'Pectorales',
        musculos: 'Pecho',
        nivel: 'INTERMEDIO',
        equipo: 'Mancuernas',
        imagenUrl: 'assets/images/aperturas_con_mancuerna.png',
        instrucciones: [
          'Acuéstate en el banco con una mancuerna en cada mano.',
          'Extiende los brazos hacia los lados formando un arco.',
          'Junta las mancuernas sobre el pecho manteniendo el codo ligeramente doblado.',
          'Regresa lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Deltoides anterior'],
      ),
      EjercicioData(
        id: 'dips_chest',
        nombre: 'Fondos en Paralelas',
        musculo: 'Pectorales inferiores',
        musculos: 'Pecho',
        nivel: 'AVANZADO',
        equipo: 'Barras paralelas',
        imagenUrl: 'assets/images/Fondos_en_paralela.png',
        instrucciones: [
          'Sujeta las barras paralelas y eleva el cuerpo.',
          'Inclínate ligeramente hacia adelante para enfatizar el pecho.',
          'Baja el cuerpo doblando los codos hasta que los hombros estén a nivel de los codos.',
          'Empuja hacia arriba extendiendo los brazos.',
        ],
        musculosSecundarios: ['Tríceps', 'Hombros'],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════════════
    // ESPALDA
    // ══════════════════════════════════════════════════════════════════════════
    'espalda': [
      EjercicioData(
        id: 'pull_up',
        nombre: 'Dominadas',
        musculo: 'Dorsal ancho',
        musculos: 'Espalda',
        nivel: 'AVANZADO',
        equipo: 'Barra de dominadas',
        imagenUrl: 'assets/images/dominadas.png',
        instrucciones: [
          'Cuelga de la barra con las manos separadas al ancho de los hombros.',
          'Activa el core y tira de los codos hacia abajo.',
          'Sube hasta que la barbilla supere la barra.',
          'Baja lentamente controlando el descenso.',
        ],
        musculosSecundarios: ['Bíceps', 'Romboides'],
      ),
      EjercicioData(
        id: 'barbell_row',
        nombre: 'Remo con Barra',
        musculo: 'Dorsal ancho',
        musculos: 'Espalda',
        nivel: 'INTERMEDIO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/remo_con_barra.png',
        instrucciones: [
          'Párate con los pies al ancho de los hombros sosteniendo la barra.',
          'Inclínate hacia adelante manteniendo la espalda recta.',
          'Tira de la barra hacia el abdomen apretando los omóplatos.',
          'Baja la barra lentamente.',
        ],
        musculosSecundarios: ['Bíceps', 'Trapecios'],
      ),
      EjercicioData(
        id: 'lat_pulldown',
        nombre: 'Jalón al Pecho',
        musculo: 'Dorsal ancho',
        musculos: 'Espalda',
        nivel: 'PRINCIPIANTE',
        equipo: 'Polea alta',
        imagenUrl: 'assets/images/jalon_al_pecho.png',
        instrucciones: [
          'Siéntate en la máquina de jalón y agarra la barra con agarre ancho.',
          'Inclínate ligeramente hacia atrás.',
          'Jala la barra hacia el pecho apretando los codos hacia abajo.',
          'Regresa lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Bíceps', 'Romboides'],
      ),
      EjercicioData(
        id: 'deadlift',
        nombre: 'Peso Muerto',
        musculo: 'Erector espinal',
        musculos: 'Espalda',
        nivel: 'AVANZADO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/peso_muerto.png',
        instrucciones: [
          'Párate con los pies al ancho de las caderas frente a la barra.',
          'Agáchate y agarra la barra con las manos fuera de las rodillas.',
          'Mantén la espalda recta y el pecho arriba.',
          'Extiende las caderas y rodillas para levantar la barra.',
          'Baja la barra controlando el movimiento.',
        ],
        musculosSecundarios: ['Glúteos', 'Isquiotibiales', 'Trapecios'],
      ),
      EjercicioData(
        id: 'seated_row',
        nombre: 'Remo en Polea Baja',
        musculo: 'Dorsal ancho',
        musculos: 'Espalda',
        nivel: 'PRINCIPIANTE',
        equipo: 'Polea baja',
        imagenUrl: 'assets/images/remo_en_polea_baja.png',
        instrucciones: [
          'Siéntate en la máquina de remo con los pies en las plataformas.',
          'Agarra el accesorio de doble agarre.',
          'Tira hacia el abdomen manteniendo la espalda erguida.',
          'Regresa lentamente extendiendo los brazos.',
        ],
        musculosSecundarios: ['Bíceps', 'Romboides'],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════════════
    // PIERNAS
    // ══════════════════════════════════════════════════════════════════════════
    'piernas': [
      EjercicioData(
        id: 'squat',
        nombre: 'Sentadilla con Barra',
        musculo: 'Cuádriceps',
        musculos: 'Piernas',
        nivel: 'INTERMEDIO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/sentadilla_con_barra.png',
        instrucciones: [
          'Coloca la barra en la parte alta de la espalda.',
          'Separa los pies al ancho de los hombros con las puntas ligeramente hacia afuera.',
          'Baja doblando las rodillas y caderas como si fueras a sentarte.',
          'Mantén el pecho arriba y la espalda recta.',
          'Sube extendiendo caderas y rodillas simultáneamente.',
        ],
        musculosSecundarios: ['Glúteos', 'Isquiotibiales', 'Core'],
      ),
      EjercicioData(
        id: 'leg_press',
        nombre: 'Prensa de Piernas',
        musculo: 'Cuádriceps',
        musculos: 'Piernas',
        nivel: 'PRINCIPIANTE',
        equipo: 'Máquina',
        imagenUrl: 'assets/images/Prensa.png',
        instrucciones: [
          'Siéntate en la prensa y coloca los pies en la plataforma.',
          'Desbloquea los seguros y baja la plataforma doblando las rodillas.',
          'Empuja la plataforma hasta extender las piernas sin bloquear las rodillas.',
          'Controla el descenso lentamente.',
        ],
        musculosSecundarios: ['Glúteos', 'Isquiotibiales'],
      ),
      EjercicioData(
        id: 'romanian_deadlift',
        nombre: 'Peso Muerto Rumano',
        musculo: 'Isquiotibiales',
        musculos: 'Piernas',
        nivel: 'INTERMEDIO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/peso_rumano.png',
        instrucciones: [
          'Párate con los pies al ancho de las caderas sosteniendo la barra.',
          'Mantén las rodillas ligeramente dobladas.',
          'Inclínate hacia adelante bajando la barra por las piernas.',
          'Siente el estiramiento en los isquiotibiales.',
          'Regresa a la posición inicial apretando los glúteos.',
        ],
        musculosSecundarios: ['Glúteos', 'Erector espinal'],
      ),
      EjercicioData(
        id: 'lunges',
        nombre: 'Zancadas',
        musculo: 'Cuádriceps',
        musculos: 'Piernas',
        nivel: 'PRINCIPIANTE',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/zancadas.png',
        instrucciones: [
          'Párate erguido con los pies juntos.',
          'Da un paso largo hacia adelante con una pierna.',
          'Baja la rodilla trasera hacia el suelo.',
          'Empuja con el pie delantero para regresar a la posición inicial.',
          'Alterna las piernas en cada repetición.',
        ],
        musculosSecundarios: ['Glúteos', 'Isquiotibiales'],
      ),
      EjercicioData(
        id: 'calf_raise',
        nombre: 'Elevaciones de Talón',
        musculo: 'Gemelos',
        musculos: 'Piernas',
        nivel: 'PRINCIPIANTE',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/elevaciones_de_talon.png',
        instrucciones: [
          'Párate con los pies al ancho de los hombros.',
          'Eleva los talones lo más alto posible.',
          'Sostén la posición de contracción por 1 segundo.',
          'Baja lentamente los talones al suelo.',
        ],
        musculosSecundarios: ['Sóleo'],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════════════
    // HOMBROS
    // ══════════════════════════════════════════════════════════════════════════
    'hombros': [
      EjercicioData(
        id: 'overhead_press',
        nombre: 'Press Militar',
        musculo: 'Deltoides',
        musculos: 'Hombros',
        nivel: 'INTERMEDIO',
        equipo: 'Barra',
        imagenUrl: 'assets/images/press_militar.png',
        instrucciones: [
          'Párate con los pies al ancho de los hombros.',
          'Agarra la barra a la altura del pecho con agarre al ancho de los hombros.',
          'Empuja la barra hacia arriba sobre la cabeza.',
          'Baja lentamente hasta la posición inicial.',
        ],
        musculosSecundarios: ['Tríceps', 'Trapecios'],
      ),
      EjercicioData(
        id: 'lateral_raise',
        nombre: 'Elevaciones Laterales',
        musculo: 'Deltoides lateral',
        musculos: 'Hombros',
        nivel: 'PRINCIPIANTE',
        equipo: 'Mancuernas',
        imagenUrl: 'assets/images/elevaciones_laterales.png',
        instrucciones: [
          'Párate con las mancuernas a los lados.',
          'Eleva los brazos hacia los lados hasta la altura de los hombros.',
          'Mantén los codos ligeramente doblados.',
          'Baja lentamente controlando el movimiento.',
        ],
        musculosSecundarios: ['Trapecios superiores'],
      ),
      EjercicioData(
        id: 'front_raise',
        nombre: 'Elevaciones Frontales',
        musculo: 'Deltoides anterior',
        musculos: 'Hombros',
        nivel: 'PRINCIPIANTE',
        equipo: 'Mancuernas',
        imagenUrl: 'assets/images/elevaciones_frontales.png',
        instrucciones: [
          'Párate con las mancuernas frente a los muslos.',
          'Eleva un brazo hacia adelante hasta la altura del hombro.',
          'Baja lentamente y repite con el otro brazo.',
          'Mantén el core activo durante el ejercicio.',
        ],
        musculosSecundarios: ['Pectorales superiores'],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════════════
    // BRAZOS
    // ══════════════════════════════════════════════════════════════════════════
    'brazos': [
      EjercicioData(
        id: 'barbell_curl',
        nombre: 'Curl de Bíceps con Barra',
        musculo: 'Bíceps',
        musculos: 'Brazos',
        nivel: 'PRINCIPIANTE',
        equipo: 'Barra',
        imagenUrl: 'assets/images/curl_de_biceps_con_barra.png',
        instrucciones: [
          'Párate con los pies al ancho de los hombros sosteniendo la barra.',
          'Mantén los codos pegados al cuerpo.',
          'Dobla los codos levantando la barra hacia los hombros.',
          'Baja lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Braquial', 'Antebrazo'],
      ),
      EjercicioData(
        id: 'tricep_pushdown',
        nombre: 'Extensión de Tríceps en Polea',
        musculo: 'Tríceps',
        musculos: 'Brazos',
        nivel: 'PRINCIPIANTE',
        equipo: 'Polea',
        imagenUrl: 'assets/images/extension_de_triceps_en_polea.png',
        instrucciones: [
          'Párate frente a la polea alta.',
          'Agarra la cuerda o barra con las manos.',
          'Mantén los codos pegados al cuerpo.',
          'Extiende los brazos hacia abajo hasta bloquear los codos.',
          'Regresa lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Antebrazo'],
      ),
      EjercicioData(
        id: 'hammer_curl',
        nombre: 'Curl Martillo',
        musculo: 'Braquial',
        musculos: 'Brazos',
        nivel: 'PRINCIPIANTE',
        equipo: 'Mancuernas',
        imagenUrl: 'assets/images/curl_martillo.png',
        instrucciones: [
          'Sostén las mancuernas con agarre neutro (pulgares arriba).',
          'Mantén los codos pegados al cuerpo.',
          'Dobla los codos levantando las mancuernas.',
          'Baja lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Bíceps', 'Antebrazo'],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════════════
    // ABDOMEN
    // ══════════════════════════════════════════════════════════════════════════
    'abdomen': [
      EjercicioData(
        id: 'crunch',
        nombre: 'Crunch Abdominal',
        musculo: 'Recto abdominal',
        musculos: 'Abdomen',
        nivel: 'PRINCIPIANTE',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/curl_abdominal.png',
        instrucciones: [
          'Acuéstate con las rodillas dobladas y pies apoyados.',
          'Coloca las manos detrás de la cabeza.',
          'Eleva los hombros del suelo contrayendo el abdomen.',
          'Regresa lentamente a la posición inicial.',
        ],
        musculosSecundarios: ['Oblicuos'],
      ),
      EjercicioData(
        id: 'plank',
        nombre: 'Plancha',
        musculo: 'Core',
        musculos: 'Abdomen',
        nivel: 'PRINCIPIANTE',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/plancha.png',
        instrucciones: [
          'Apóyate en los antebrazos y puntas de los pies.',
          'Mantén el cuerpo recto como una tabla.',
          'Activa el abdomen y los glúteos.',
          'Sostén la posición el tiempo indicado.',
          'Respira de manera controlada durante el ejercicio.',
        ],
        musculosSecundarios: ['Glúteos', 'Hombros'],
      ),
      EjercicioData(
        id: 'leg_raise',
        nombre: 'Elevación de Piernas',
        musculo: 'Recto abdominal inferior',
        musculos: 'Abdomen',
        nivel: 'INTERMEDIO',
        equipo: 'Sin equipo',
        imagenUrl: 'assets/images/elevaciones_de_pierna.png',
        instrucciones: [
          'Acuéstate con las piernas extendidas.',
          'Coloca las manos debajo de los glúteos.',
          'Eleva las piernas hasta 90 grados.',
          'Baja lentamente sin tocar el suelo.',
        ],
        musculosSecundarios: ['Flexores de cadera'],
      ),
    ],
  };

  Future<List<EjercicioData>> getEjerciciosPorGrupo(String grupoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db[grupoId.toLowerCase()] ?? [];
  }

  Future<EjercicioData?> getEjercicioPorId(String id) async {
    for (final lista in _db.values) {
      final match = lista.where((e) => e.id == id);
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }
}
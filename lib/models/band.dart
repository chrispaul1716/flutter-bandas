class Banda {
  
  String id;
  String nombre;
  int votos;

  Banda({
    this.id,
    this.nombre,
    this.votos
  });

  factory Banda.fromMap(Map<String, dynamic> obj) 
  => Banda(
    id    : obj.containsKey('id') ? obj['id'] : 'no-id',
    nombre: obj.containsKey('nombre') ? obj['nombre'] : 'no-nombre',
    votos : obj.containsKey('votos') ? obj['votos'] : 'no-votos'
  );

}
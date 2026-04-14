/// ─── Configuración de Cloudinary ─────────────────────────────────────────────
///
/// CÓMO OBTENER ESTOS VALORES:
///   1. Crea una cuenta gratuita en https://cloudinary.com
///   2. Ve a Dashboard → copia Cloud Name, API Key y API Secret
///   3. En Cloudinary → Settings → Upload → Add upload preset
///      - Signing Mode: UNSIGNED  ← importante para subir desde la app
///      - Folder: avatars/        ← opcional, para organizar
///      - Copia el nombre del preset
///
/// PLAN GRATUITO de Cloudinary:
///   - 25 GB de almacenamiento
///   - 25 GB de ancho de banda mensual
///   - Transformaciones ilimitadas
///   → Más que suficiente para miles de avatares de perfil.
///
/// SEGURIDAD:
///   - cloudName y uploadPreset son seguros para estar en el cliente.
///   - apiKey y apiSecret NUNCA deben ir en el cliente en producción.
///     Para este caso usamos un upload preset UNSIGNED, que no requiere
///     apiSecret desde el dispositivo.
class CloudinaryConfig {
  CloudinaryConfig._();

  /// Tu Cloud Name (visible en el Dashboard de Cloudinary)
  static const String cloudName = 'dwmmpza2r';

  /// Nombre del upload preset UNSIGNED que creaste
  static const String uploadPreset = 'foto_perfil';

  /// Carpeta donde se guardarán los avatares en Cloudinary
  static const String avatarFolder = 'avatars';

  /// URL base de la API de upload de Cloudinary
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Genera la URL de transformación para mostrar el avatar:
  /// redimensiona a [size]×[size] px, recorte centrado, calidad automática.
  /// Esto lo hace Cloudinary al vuelo — no necesitas preprocesar la imagen.
  static String transformAvatarUrl(String publicId, {int size = 200}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload'
        '/c_fill,g_face,w_$size,h_$size,q_auto,f_auto/$publicId';
  }
}

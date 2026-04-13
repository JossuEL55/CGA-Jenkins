using System;
using System.Collections.Generic;
using System.Text;

namespace CGA.MetrologySystem.Domain.Entities
{
    public class TipoDocumento
    {
        public int TipoDocumentoId { get; set; }
        public string Nombre { get; set; } = string.Empty;
    }
}

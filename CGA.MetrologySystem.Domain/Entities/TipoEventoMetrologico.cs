using System;
using System.Collections.Generic;
using System.Text;

namespace CGA.MetrologySystem.Domain.Entities
{
    public class TipoEventoMetrologico
    {
        public int TipoEventoMetrologicoId { get; set; }
        public string Nombre { get; set; } = string.Empty;
    }
}
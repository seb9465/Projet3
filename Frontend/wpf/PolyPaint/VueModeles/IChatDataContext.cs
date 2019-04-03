using PolyPaint.Modeles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.VueModeles
{
    public interface IChatDataContext
    {
        ChatClient ChatClient { get; set; }
        string CurrentRoom { get; set; }
    }
}

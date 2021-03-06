﻿using PolyPaint.Common.Collaboration;
using System.Collections.Generic;

namespace PolyPaint.Common.Messages
{
    public class ItemsMessage
    {
        public string CanvasId { get; set; }
        public string Username { get; set; }
        public List<DrawViewModel> Items { get; set; }
        public ItemsMessage(string canvasId, string username, List<DrawViewModel> items)
        {
            CanvasId = canvasId;
            Username = username;
            Items = items;
        }
    }
}

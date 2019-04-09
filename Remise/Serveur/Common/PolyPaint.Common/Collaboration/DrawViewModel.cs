using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;

namespace PolyPaint.Common.Collaboration
{
    [Serializable]
    public class DrawViewModel
    {
        public string Guid { get; set; }
        public string Owner { get; set; }
        public ItemTypeEnum ItemType { get; set; }
        public List<PolyPaintStylusPoint> StylusPoints { get; set; }
        public PolyPaintColor FillColor { get; set; }
        public PolyPaintColor BorderColor { get; set; }
        public double BorderThickness { get; set; }
        public string BorderStyle { get; set; }
        public string ShapeTitle { get; set; }
        public List<string> Methods { get; set; }
        public List<string> Properties { get; set; }
        public string SourceTitle { get; set; }
        public string DestinationTitle { get; set; }
        public string ChannelId { get; set; } = "general";
        public string OutilSelectionne { get; set; }
        public PolyPaintStylusPoint LastElbowPosition { get; set; }
        public byte[] ImageBytes { get; set; }
        public double Rotation { get; set; }
        // Guid, Side
        public List<List<string>> InConnections;
        public List<List<string>> OutConnections;

        [JsonIgnore]
        public List<PolyPaintStylusPoint> RotatedStylusPoints
        {
            get { return StylusPoints.ToList().Select(x => RotatePoint(new PolyPaintStylusPoint(x.X, x.Y), Center, -Rotation)).ToList(); }
        }

        [JsonIgnore]
        public PolyPaintStylusPoint Center
        {
            get { return new PolyPaintStylusPoint((StylusPoints[1].X + StylusPoints[0].X) / 2, (StylusPoints[1].Y + StylusPoints[0].Y) / 2); }
        }

        public bool IsConnection()
        {
            var connections = new List<ItemTypeEnum>()
            {
                ItemTypeEnum.Agregation,
                ItemTypeEnum.Composition,
                ItemTypeEnum.Line,
                ItemTypeEnum.UnidirectionalAssociation,
                ItemTypeEnum.Inheritance,
                ItemTypeEnum.BidirectionalAssociation,
            };
            return connections.Contains(ItemType);
        }

        [JsonIgnore]
        private readonly JsonSerializerSettings SerializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new DefaultContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };

        public override string ToString() => JsonConvert.SerializeObject(this, SerializerSettings);

        public static PolyPaintStylusPoint RotatePoint(PolyPaintStylusPoint p1, PolyPaintStylusPoint p2, double angle)
        {
            double radians = ConvertToRadians(angle);
            double sin = Math.Sin(radians);
            double cos = Math.Cos(radians);

            // Translate point back to origin
            p1.X -= p2.X;
            p1.Y -= p2.Y;

            // Rotate point
            double xnew = p1.X * cos - p1.Y * sin;
            double ynew = p1.X * sin + p1.Y * cos;

            // Translate point back
            PolyPaintStylusPoint newPoint = new PolyPaintStylusPoint(xnew + p2.X, ynew + p2.Y);
            return newPoint;
        }

        public static double ConvertToRadians(double angle)
        {
            return (Math.PI / 180) * angle;
        }

        public static double ConvertToDegrees(double angle)
        {
            return angle * (180 / Math.PI);
        }
    }
}

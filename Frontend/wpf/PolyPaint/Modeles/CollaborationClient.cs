using Microsoft.AspNetCore.SignalR.Client;using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Structures;using PolyPaint.Utilitaires;
using System;using System.Collections.Generic;using System.Threading.Tasks;using System.Windows;

namespace PolyPaint.Modeles{    public class CollaborationClient    {        public event EventHandler<MessageArgs> DrawReceived;        public event EventHandler<MessageArgs> ResetReceived;        public event EventHandler<MessageArgs> ResizeCanvasReceived;        public event EventHandler<MessageArgs> DeleteReceived;        public event EventHandler<MessageArgs> SelectReceived;        public event EventHandler<MessageArgs> DuplicateReceived;        public event EventHandler<MessageArgs> KickedReceived;        public event EventHandler<MessageArgs> ProtectionChanged;        public event EventHandler<RoutedEventArgs> ClientConnected;        private HubConnection Connection { get; set; }        private List<Channel> Channels { get; set; }        private string ChannelId { get; set; }        public CollaborationClient(string channelId)        { ChannelId = channelId; }        public async void Initialize(string accessToken)        {            Connection =                new HubConnectionBuilder()                .WithUrl($"{Config.URL}/signalr/collaborative?channelId={ChannelId}", options =>                {                    options.AccessTokenProvider = () => Task.FromResult(accessToken);                })                .Build();            HandleMessages();            try
            {
                await Connection.StartAsync();            }
            catch (Exception)
            { }        }        private void HandleMessages()
        {
            Connection.On<string>("Draw", (drawViewModelString) =>
            {
                DrawReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Select", (drawViewModels) =>
            {
                SelectReceived?.Invoke(this, new MessageArgs(message: drawViewModels));
            });
            Connection.On<string>("Duplicate", (drawViewModelString) =>
            {
                DuplicateReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On<string>("Cut", (drawViewModelString) =>
            {
                DeleteReceived?.Invoke(this, new MessageArgs(message: drawViewModelString));
            });
            Connection.On("Reset", () =>
            {
                ResetReceived?.Invoke(this, new MessageArgs());
            });
            Connection.On<string>("ResizeCanvas", (sizeMessageString) =>
            {
                ResizeCanvasReceived?.Invoke(this, new MessageArgs(message: sizeMessageString));
            });
            Connection.On("Kicked", () =>
            {
                KickedReceived?.Invoke(this, new MessageArgs());
            });
            Connection.On<string>("ChangeProtection", (message) =>
            {
                ProtectionChanged?.Invoke(this, new MessageArgs(message: message));
            });
            Connection.On<string>("ConnectToChannel", (connectionMessage) =>
            {
                var message = JsonConvert.DeserializeObject<ConnectionMessage>(connectionMessage);
                Console.WriteLine($"[ COLLAB ] Connected to channel: {message.ChannelId}");
                ClientConnected?.Invoke(this, new RoutedEventArgs());
            });
        }        public async void CollaborativeDrawAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Draw(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeSelectAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Select(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeDeleteAsync(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Delete(drawViewModels);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeResetAsync()
        {
            try
            {
                await Reset();
            }
            catch (Exception)
            { }
        }

        public async void CollaborativeResizeCanvasAsync(Point size)
        {
            try
            {
                await ResizeCanvas(size);
            }
            catch (Exception)
            { }
        }        public async void CollaborativeChangeProtectionAsync(string canvasId, bool isProtected)
        {
            try
            {
                await ChangeProtection(canvasId, isProtected);
            }
            catch (Exception)
            {
            }
        }
        private async Task Draw(List<DrawViewModel> drawViewModels)
        {
            try
            {
                var mess = JsonConvert.SerializeObject(new ItemsMessage(ChannelId, "", drawViewModels));
                await Connection.InvokeAsync("Draw", mess);
            }
            catch (Exception) { }
        }

        private async Task Select(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Select", JsonConvert.SerializeObject(new ItemsMessage(ChannelId, "", drawViewModels)));
            }
            catch (Exception) { }
        }

        public async Task CollaborativeDuplicateAsync()
        {
            object o = Clipboard.GetDataObject();

            try
            {
                await Connection.InvokeAsync("Duplicate");
            }
            catch (Exception) { }
        }

        public async Task Delete(List<DrawViewModel> drawViewModels)
        {
            try
            {
                await Connection.InvokeAsync("Cut", JsonConvert.SerializeObject(new ItemsMessage(ChannelId, "", drawViewModels)));
            }
            catch (Exception) { }
        }

        public async Task Reset()
        {
            try
            {
                await Connection.InvokeAsync("Reset");
            }
            catch (Exception) { }
        }

        public async Task ResizeCanvas(Point size)
        {
            try
            {
                await Connection.InvokeAsync("ResizeCanvas", JsonConvert.SerializeObject(new SizeMessage(new PolyPaintStylusPoint(size.X, size.Y))));
            }
            catch (Exception) { }
        }

        public async Task ChangeProtection(string canvasId, bool isProtected)
        {
            try
            {
                await Connection.InvokeAsync("ChangeProtection", JsonConvert.SerializeObject(new ProtectionMessage(canvasId, isProtected)));
            }
            catch (Exception) { }
        }

        public async void CreateGroup(string canvasName)
        {
            try
            {
                await CollabCreateGroupAsync(canvasName);
                await CollabConnectToGroupAsync(canvasName);
            }
            catch (Exception)
            {
            }
        }

        private async Task CollabConnectToGroupAsync(string canvasName)
        {
            await Connection.SendAsync("ConnectToChannel", (new ConnectionMessage(channelId: canvasName)).ToString());
        }

        private async Task CollabCreateGroupAsync(string canvasName)
        {            await Connection.SendAsync("CreateChannel", (new ChannelMessage(new Channel(canvasName, false))).ToString());
        }        public async Task Disconnect()
        {
            await Connection.StopAsync();
        }
    }
}
using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Structures;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Modeles
{
    class ChatClient
    {
        public event EventHandler<MessageArgs> MessageReceived;
        //public event EventHandler<MessageArgs> SystemMessageReceived;
        public event EventHandler ChannelsReceived;
        public event EventHandler<ChannelArgs> ChannelCreated;
        public event EventHandler<MessageArgs> ConnectedToChannel;
        public event EventHandler<MessageArgs> ConnectedToChannelSender;
        public event EventHandler<MessageArgs> DisconnectedFromChannel;
        public event EventHandler<MessageArgs> DisconnectedFromChannelSender;
        private HubConnection Connection { get; set; }
        private List<Channel> Channels { get; set; }


        public ChatClient()
        { }

        public async void Initialize(string accessToken)
        {
            Connection =
                new HubConnectionBuilder()
                .WithUrl($"{Config.URL}/signalr", options =>
                {
                    options.AccessTokenProvider = () => Task.FromResult(accessToken);
                })
                .Build();

            HandleMessages();
            await Connection.StartAsync();
            await Connection.SendAsync("FetchChannels");
        }

        private void HandleMessages()
        {
            Connection.On<ChatMessage>("SendMessage", (chatMessage) =>
            {
                MessageReceived?.Invoke(this, new MessageArgs(chatMessage.Username, chatMessage.Message, chatMessage.Timestamp, chatMessage.ChannelId));
            });
            Connection.On<ChannelsMessage>("FetchChannels", (channelsMessage) =>
            {
                Channels = channelsMessage.Channels;
                ChannelsReceived?.Invoke(this, null);
            });
            Connection.On<ChannelMessage>("CreateChannel", (channelMessage) =>
            {
                ChannelCreated?.Invoke(this, new ChannelArgs(channelMessage.Channel));
            });
            Connection.On<ConnectionMessage>("ConnectToChannel", (connectionMessage) =>
            {
                ConnectedToChannel?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));
            });
            Connection.On<ConnectionMessage>("ConnectToChannelSender", (connectionMessage) =>
            {
                ConnectedToChannelSender?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));
            });
            Connection.On<ConnectionMessage>("DisconnectFromChannel", (connectionMessage) =>
            {
                DisconnectedFromChannel?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));
            });
            Connection.On<ConnectionMessage>("DisconnectFromChannelSender", (connectionMessage) =>
            {
                DisconnectedFromChannelSender?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));
            });
        }

        public async void SendMessage(string message, string channel)
        {
            await Connection.SendAsync("SendMessage", new ChatMessage(message: message, channelId: channel));
        }

        public async void CreateChannel(string name)
        {
            await Connection.SendAsync("CreateChannel", new ChannelMessage(new Channel(name)));
        }

        public async void DisconnectFromChannel(string name)
        {
            await Connection.SendAsync("DisconnectFromChannel", new ConnectionMessage(channelId: name));
        }

        public async void ConnectToChannel(string name)
        {
            await Connection.SendAsync("ConnectToChannel", new ConnectionMessage(channelId: name));
        }

        public List<Channel> GetChannels()
        {
            return Channels;
        }
    }
}

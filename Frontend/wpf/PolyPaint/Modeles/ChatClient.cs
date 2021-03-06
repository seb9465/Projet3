﻿using Microsoft.AspNetCore.SignalR.Client;using Newtonsoft.Json;using PolyPaint.Common.Messages;
using PolyPaint.Structures;using System;using System.Collections.Concurrent;
using System.Collections.Generic;using System.Collections.ObjectModel;
using System.Threading.Tasks;namespace PolyPaint.Modeles{    public class ChatClient    {        public event EventHandler<MessageArgs> MessageReceived;        public event EventHandler ChannelsReceived;        public event EventHandler<ChannelArgs> ChannelCreated;        public event EventHandler<MessageArgs> ConnectedToChannel;        public event EventHandler<MessageArgs> ConnectedToChannelSender;        public event EventHandler<MessageArgs> DisconnectedFromChannel;        public event EventHandler<MessageArgs> DisconnectedFromChannelSender;        private HubConnection Connection { get; set; }        private List<Channel> Channels { get; set; }

        public ConcurrentDictionary<string, ObservableCollection<string>> MessagesByChannel { get; set; }
        public ObservableCollection<Room> Rooms { get; set; }        public ChatClient()        {
            MessagesByChannel = new ConcurrentDictionary<string, ObservableCollection<string>>();
            Rooms = new ObservableCollection<Room>();
        }        public async void Initialize(string accessToken)        {            Connection =                new HubConnectionBuilder()                .WithUrl($"{Config.URL}/signalr", options =>                {                    options.AccessTokenProvider = () => Task.FromResult(accessToken);                })                .Build();            HandleMessages();            await Connection.StartAsync();            await Connection.SendAsync("FetchChannels");        }        private void HandleMessages()        {            Connection.On<string>("SendMessage", (message) =>            {                var chatMessage = JsonConvert.DeserializeObject<ChatMessage>(message);                MessageReceived?.Invoke(this, new MessageArgs(chatMessage.Username, chatMessage.Message, chatMessage.Timestamp, chatMessage.ChannelId));            });            Connection.On<string>("FetchChannels", (channelsMessage) =>            {                Channels = JsonConvert.DeserializeObject<ChannelsMessage>(channelsMessage).Channels;                ChannelsReceived?.Invoke(this, null);            });            Connection.On<string>("CreateChannel", (message) =>            {                var channelMessage = JsonConvert.DeserializeObject<ChannelMessage>(message);                ChannelCreated?.Invoke(this, new ChannelArgs(channelMessage.Channel));            });            Connection.On<string>("ConnectToChannel", (message) =>            {                var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);                ConnectedToChannel?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));            });            Connection.On<string>("ConnectToChannelSender", (message) =>            {                var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);                ConnectedToChannelSender?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));            });            Connection.On<string>("DisconnectFromChannel", (message) =>            {                var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);                DisconnectedFromChannel?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));            });            Connection.On<string>("DisconnectFromChannelSender", (message) =>            {                var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);                DisconnectedFromChannelSender?.Invoke(this, new MessageArgs(username: connectionMessage.Username, message: connectionMessage.ChannelId));            });        }        public async void SendMessage(string message, string channel)        {            try
            {
                await Connection.SendAsync("SendMessage", (new ChatMessage(message: message, channelId: channel)).ToString());
            }
            catch (Exception)
            {
            }        }        public async void CreateChannel(string name)        {            try
            {
                await Connection.SendAsync("CreateChannel", (new ChannelMessage(new Channel(name, false))).ToString());
            }
            catch (Exception)
            {
            }        }        public async void DisconnectFromChannel(string name)        {            try
            {
                await Connection.SendAsync("DisconnectFromChannel", (new ConnectionMessage(channelId: name)).ToString());
            }
            catch (Exception)
            {
            }        }        public async void ConnectToChannel(string name)        {            try
            {
                await Connection.SendAsync("ConnectToChannel", (new ConnectionMessage(channelId: name)).ToString());
            }
            catch (Exception)
            {
            }        }        public List<Channel> GetChannels()        {            return Channels;        }        public async Task Disconnect()
        {
            try
            {
                await Connection.StopAsync();
            }
            catch (Exception)
            {
            }
        }    }}
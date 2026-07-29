import React, { useState } from 'react';
import axios from 'axios';

const products = [
  { id: 1, name: 'Samsung 55" QLED', price: 899, category: 'tv', img: 'https://picsum.photos/id/1015/300/200' },
  { id: 2, name: 'LG 65" OLED', price: 1299, category: 'tv', img: 'https://picsum.photos/id/106/300/200' },
  { id: 3, name: 'iPhone 15 Pro', price: 999, category: 'phone', img: 'https://picsum.photos/id/180/300/200' },
  { id: 4, name: 'Samsung S24', price: 899, category: 'phone', img: 'https://picsum.photos/id/201/300/200' },
  { id: 5, name: 'MacBook Air M3', price: 1099, category: 'computer', img: 'https://picsum.photos/id/160/300/200' },
  { id: 6, name: 'Dell XPS 13', price: 999, category: 'computer', img: 'https://picsum.photos/id/29/300/200' },
  { id: 7, name: 'Sony 75" Bravia', price: 1599, category: 'tv', img: 'https://picsum.photos/id/133/300/200' },
  { id: 8, name: 'Google Pixel 8', price: 699, category: 'phone', img: 'https://picsum.photos/id/251/300/200' },
  { id: 9, name: 'Lenovo ThinkPad', price: 849, category: 'computer', img: 'https://picsum.photos/id/250/300/200' },
  { id: 10, name: 'OnePlus 12', price: 799, category: 'phone', img: 'https://picsum.photos/id/160/300/200' },
  { id: 11, name: 'Realme 12 Pro', price: 399, category: 'phone', img: 'https://picsum.photos/id/201/300/200' },
  { id: 12, name: 'Xiaomi 14', price: 849, category: 'phone', img: 'https://picsum.photos/id/180/300/200' },
  { id: 13, name: ' TCL 43" Smart TV', price: 399, category: 'tv', img: 'https://picsum.photos/id/106/300/200' },
  { id: 14, name: 'Insignia 50" 4K', price: 449, category: 'tv', img: 'https://picsum.photos/id/133/300/200' },
  { id: 15, name: 'Hisense 55" ULED', price: 699, category: 'tv', img: 'https://picsum.photos/id/1015/300/200' },
  { id: 16, name: 'HP Pavilion 15', price: 699, category: 'computer', img: 'https://picsum.photos/id/29/300/200' },
  { id: 17, name: 'Acer Aspire 5', price: 549, category: 'computer', img: 'https://picsum.photos/id/160/300/200' },
  { id: 18, name: 'ASUS VivoBook 16', price: 629, category: 'computer', img: 'https://picsum.photos/id/250/300/200' }
];

function App() {
  const [cart, setCart] = useState([]);
  const [activeTab, setActiveTab] = useState('all');
  const [showCart, setShowCart] = useState(false);
  const [showOrder, setShowOrder] = useState(false);
  const [showTracking, setShowTracking] = useState(false);
  const [showTicket, setShowTicket] = useState(false);
  const [orderData, setOrderData] = useState({ address: '', payment: '' });
  const [trackingId, setTrackingId] = useState('');
  const [trackingResult, setTrackingResult] = useState(null);
  const [ticketData, setTicketData] = useState({ orderId: '', issue: '' });

  const addToCart = (product) => {
    setCart([...cart, product]);
  };

  const removeFromCart = (index) => {
    const newCart = cart.filter((_, i) => i !== index);
    setCart(newCart);
  };

  const total = cart.reduce((sum, item) => sum + item.price, 0);

  const filtered = activeTab === 'all' ? products : products.filter(p => p.category === activeTab);

  const placeOrder = async () => {
    try {
      const res = await axios.post('http://localhost:5000/order', {
        items: cart,
        address: orderData.address,
        payment: orderData.payment,
        total
      });
      alert('Order placed! ID: ' + res.data.orderId);
      setCart([]);
      setShowOrder(false);
      setShowCart(false);
    } catch (err) {
      alert('Order failed');
    }
  };

  const trackOrder = async () => {
    try {
      const res = await axios.get(`http://localhost:5000/tracking/${trackingId}`);
      setTrackingResult(res.data);
    } catch (err) {
      alert('Tracking failed');
    }
  };

  const submitTicket = async () => {
    try {
      await axios.post('http://localhost:5000/ticket', ticketData);
      alert('Ticket submitted');
      setShowTicket(false);
      setTicketData({ orderId: '', issue: '' });
    } catch (err) {
      alert('Ticket failed');
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', background: '#2874f0', color: 'white', padding: '15px 30px', alignItems: 'center' }}>
        <h1 style={{ margin: 0, fontSize: '28px', fontWeight: 'bold' }}>ShoppingCart</h1>
        <div>
          <button onClick={() => setShowTracking(true)}>Track</button>
          <button onClick={() => setShowTicket(true)}>Support</button>
          <button onClick={() => setShowCart(true)}>Cart ({cart.length})</button>
        </div>
      </div>

      <div style={{ display: 'flex', gap: '0', margin: '20px 0', background: '#f1f3f6', padding: '4px', borderRadius: '4px' }}>
        {['all','tv','phone','computer'].map(tab => {
          const colors = { all: '#2874f0', tv: '#ff5722', phone: '#4caf50', computer: '#9c27b0' };
          return (
            <button key={tab} onClick={() => setActiveTab(tab)} style={{
              background: activeTab === tab ? colors[tab] : 'transparent',
              color: activeTab === tab ? 'white' : '#333',
              padding: '10px 25px',
              border: 'none',
              borderRadius: '4px',
              fontWeight: '600',
              cursor: 'pointer'
            }}>
              {tab.toUpperCase()}
            </button>
          );
        })}
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
        gap: '20px',
        padding: '30px',
        background: activeTab === 'all' ? 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' :
                   activeTab === 'tv' ? 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' :
                   activeTab === 'phone' ? 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' :
                   'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
        minHeight: '500px',
        borderRadius: '12px',
        boxShadow: '0 10px 30px rgba(0,0,0,0.2)'
      }}>
        {filtered.map(p => (
          <div key={p.id} style={{ border: '1px solid #ddd', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}>
            <img src={p.img} alt={p.name} style={{ width: '100%', height: '160px', objectFit: 'cover' }} />
            <div style={{ padding: '15px' }}>
              <h3 style={{ margin: '0 0 8px', fontSize: '15px', color: '#212121' }}>{p.name}</h3>
              <p style={{ fontSize: '18px', fontWeight: '600', color: '#212121' }}>${p.price}</p>
              <button onClick={() => addToCart(p)} style={{ background: '#ff9f00', color: '#fff', border: 'none', padding: '10px 20px', width: '100%', borderRadius: '2px', fontWeight: '600' }}>ADD TO CART</button>
            </div>
          </div>
        ))}
      </div>

      {showCart && (
        <div style={{ position: 'fixed', top: '50px', right: '20px', background: 'white', border: '1px solid', padding: '20px', width: '300px' }}>
          <h2>Cart</h2>
          {cart.length === 0 ? <p>Empty</p> : cart.map((item, i) => (
            <div key={i}>{item.name} - ${item.price} <button onClick={() => removeFromCart(i)}>x</button></div>
          ))}
          <p>Total: ${total}</p>
          <button onClick={() => { setShowCart(false); setShowOrder(true); }}>Checkout</button>
          <button onClick={() => setShowCart(false)}>Close</button>
        </div>
      )}

      {showOrder && (
        <div style={{ position: 'fixed', top: '100px', left: '50%', transform: 'translateX(-50%)', background: 'white', border: '1px solid', padding: '20px', width: '400px' }}>
          <h2>Order</h2>
          <input placeholder="Address" value={orderData.address} onChange={e => setOrderData({ ...orderData, address: e.target.value })} style={{ width: '100%', marginBottom: '10px' }} />
          <input placeholder="Payment" value={orderData.payment} onChange={e => setOrderData({ ...orderData, payment: e.target.value })} style={{ width: '100%', marginBottom: '10px' }} />
          <button onClick={placeOrder}>Place Order</button>
          <button onClick={() => setShowOrder(false)}>Cancel</button>
        </div>
      )}

      {showTracking && (
        <div style={{ position: 'fixed', top: '100px', left: '50%', transform: 'translateX(-50%)', background: 'white', border: '1px solid', padding: '20px', width: '400px' }}>
          <h2>Track Order</h2>
          <input placeholder="Order ID" value={trackingId} onChange={e => setTrackingId(e.target.value)} style={{ width: '100%', marginBottom: '10px' }} />
          <button onClick={trackOrder}>Track</button>
          {trackingResult && <pre>{JSON.stringify(trackingResult, null, 2)}</pre>}
          <button onClick={() => { setShowTracking(false); setTrackingResult(null); }}>Close</button>
        </div>
      )}

      {showTicket && (
        <div style={{ position: 'fixed', top: '100px', left: '50%', transform: 'translateX(-50%)', background: 'white', border: '1px solid', padding: '20px', width: '400px' }}>
          <h2>Support Ticket</h2>
          <input placeholder="Order ID" value={ticketData.orderId} onChange={e => setTicketData({ ...ticketData, orderId: e.target.value })} style={{ width: '100%', marginBottom: '10px' }} />
          <textarea placeholder="Issue" value={ticketData.issue} onChange={e => setTicketData({ ...ticketData, issue: e.target.value })} style={{ width: '100%', marginBottom: '10px' }} />
          <button onClick={submitTicket}>Submit</button>
          <button onClick={() => setShowTicket(false)}>Cancel</button>
        </div>
      )}
    </div>
  );
}

export default App;
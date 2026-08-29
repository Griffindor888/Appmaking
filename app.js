const menu=document.querySelector('.menu');
const links=document.querySelector('.navlinks');
if(menu&&links){menu.addEventListener('click',()=>{const open=links.style.display==='flex';links.style.display=open?'none':'flex';if(!open){Object.assign(links.style,{position:'absolute',top:'68px',left:'0',right:'0',background:'#fff',padding:'18px 20px',flexDirection:'column',alignItems:'flex-start',borderBottom:'1px solid #dfe4ea'});}})}

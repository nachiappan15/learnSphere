import './App.css';
import { Route, Routes } from 'react-router-dom';
import HomePage from './pages/HomePage/HomePage';

function App() {
  return (
    <Routes>
      <Route index element={<HomePage/>}/>
    </Routes>
  );
}

export default App;

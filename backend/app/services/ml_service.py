import os
import sys
from uuid import UUID
from datetime import datetime
import torch

# Add ML_cyberav to path if not already there
ML_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "ML_cyberav"))
if ML_PATH not in sys.path:
    sys.path.append(ML_PATH)

from eta_system.dl.inference import DLInference
from eta_system.graph import routing
from eta_system import config

class MLService:
    _instance = None
    _inference = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MLService, cls).__new__(cls)
            try:
                # Initialize the underlying DL inference engine
                cls._inference = DLInference()
            except Exception as e:
                print(f"Failed to initialize ML Inference: {e}")
        return cls._instance

    def predict_eta_multiplier(self, pickup_lat: float, pickup_lon: float, drop_lat: float, drop_lon: float, timestamp: datetime = None):
        """
        Calculates the ML-based ETA multiplier for a given route.
        """
        if not self._inference:
            return 1.0 # Fallback to neutral multiplier

        if timestamp is None:
            timestamp = datetime.now()

        # In a real scenario, we would compute the zones involved in the route.
        # For simplicity and based on the provided logic, we can get the multiplier 
        # for the starting zone or an average across the route.
        
        try:
            # Get nearest node/zone for start and end
            start_node = routing.get_nearest_node(self._inference.G, pickup_lat, pickup_lon)
            
            start_zone = self._inference.clusterer.get_zone_by_node(start_node)
            
            # For now, let's use a simplified approach: 
            # Predict for all zones and extract the one for the start location.
            # In a full production system, we'd pass the actual feature tensors.
            # Here we assume dummy feature tensors as we don't have the real-time collector hooked up.
            
            # This is a placeholder for the actual feature extraction logic
            # which would normally happen in a data pipeline.
            num_zones = config.NUM_ZONES
            dummy_current = torch.randn(num_zones, 4) 
            dummy_history = torch.randn(num_zones, 24, 2)
            
            multipliers = self._inference.predict(dummy_current, dummy_history)
            
            if start_zone is not None and 0 <= start_zone < len(multipliers):
                return float(multipliers[start_zone])
            
            return 1.0
        except Exception as e:
            print(f"Error during ML prediction: {e}")
            return 1.0

ml_service = MLService()

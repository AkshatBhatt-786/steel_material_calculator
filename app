from flask import Flask, render_template, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PRICING = {
    "JSW": {
        "COLOURON+": {
            "0.5": 140,
            "0.6": 140
        },
        "Pragati": {
            "0.5": 130,
            "0.6": 130
        }
    },
    "AMNS": {
        "Standard": {
            "0.5": 120,
            "0.6": 120
        }
    }
}

COLOR_PREMIUM = {
    "White": 0,
    "Blue": 0,
    "Black": 0,
    "Grey": 0
}

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['company', 'type', 'thickness', 'color', 'length', 'pieces', 'width']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400
        
        # Parse numeric values
        try:
            company = data["company"]
            product_type = data["type"]
            thickness = data["thickness"]
            color = data["color"]
            length = float(data["length"])
            pieces = float(data["pieces"])
            width = float(data["width"])
        except (ValueError, TypeError) as e:
            return jsonify({"error": f"Invalid data type: {str(e)}"}), 400
        
        # Validate pricing exists
        if company not in PRICING:
            return jsonify({"error": f"Invalid company: {company}"}), 400
            
        if product_type not in PRICING[company]:
            return jsonify({"error": f"Invalid product type: {product_type}"}), 400
            
        if thickness not in PRICING[company][product_type]:
            return jsonify({"error": f"Invalid thickness: {thickness}"}), 400
            
        if color not in COLOR_PREMIUM:
            return jsonify({"error": f"Invalid color: {color}"}), 400
        
        # Validate dimensions
        if length <= 0 or pieces <= 0 or width <= 0:
            return jsonify({"error": "Dimensions must be positive numbers"}), 400
        
        # Calculate prices
        base_price = PRICING[company][product_type][thickness]
        color_price = COLOR_PREMIUM[color]
        final_price_per_sqft = base_price + color_price
        total_area = length * pieces * width
        total_price = total_area * final_price_per_sqft

        response = {
            "company": company,
            "type": product_type,
            "thickness": thickness,
            "color": color,
            "length": length,
            "pieces": pieces,
            "width": width,
            "total_area": round(total_area, 2),
            "price_per_sqft": final_price_per_sqft,
            "base_price": base_price,
            "color_price": color_price,
            "total_price": round(total_price, 2)
        }

        return jsonify(response)
    
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True)

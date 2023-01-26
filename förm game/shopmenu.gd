extends StaticBody2D

#item 1 = berry 2 = randomseed
var item = 1

var item1price = 100
var item2price = 250

var item1owned = false
var item2owned = false

var price

func _ready():
	$icon.play("berryseed")
	item = 1
	
func _physics_process(delta):
	if self.visible == true:
		if item == 1:
			$icon.play("berryseed")
			$pricelabel.text = "100"
			if Global.coins >= item1price:
				if item1owned == false:
					$buttonbuycolor.color = "624e803c" #green
				else:
					$buttonbuycolor.color = "62803c3c" #red
			else:
				$buttonbuycolor.color = "62803c3c" #red
		if item == 2:
			$icon.play("randomseed")
			$pricelabel.text = "250"
			if Global.coins >= item2price:
				if item2owned == false:
					$buttonbuycolor.color = "624e803c" #green
				else:
					$buttonbuycolor.color = "62803c3c" #red
			else:
				$buttonbuycolor.color = "62803c3c" #red

func _on_buttonleft_pressed():
	swap_item_back()
func _on_buttonright_pressed():
	swap_item_forward()
func _on_buttonbuy_pressed():
	if item == 1:
		price = item1price
		if Global.coins >= price:
			if item1owned == false:
				buy()
	elif item == 2:
		price = item2price
		if Global.coins >= price:
			if item2owned == false:
				buy()
				
func buy():
	Global.coins -= price
	if item == 1:
		item1owned = true
	if item == 2:
		item2owned = true
	
func swap_item_back():
	if item == 1:
		item = 2
	elif item == 2:
		item = 1
		
func swap_item_forward():
	if item == 1:
		item = 2
	elif item == 2:
		item = 1

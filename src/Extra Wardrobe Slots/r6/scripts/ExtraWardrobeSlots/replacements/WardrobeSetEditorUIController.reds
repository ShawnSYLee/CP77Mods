@addField(WardrobeSetEditorUIController)
private let m_wardrobeSystemExtra: wref<WardrobeSystemExtra>;

@addField(WardrobeSetEditorUIController)
private let m_currentSetExtra: wref<ClothingSetExtra>;

@wrapMethod(WardrobeSetEditorUIController)
public final func Initialize(player: wref<PlayerPuppet>, tooltipsManager: wref<gameuiTooltipsManager>, buttonHintsController: wref<ButtonHints>, gameController: wref<WardrobeUIGameController>) -> Void {
  wrappedMethod(player, tooltipsManager, buttonHintsController, gameController);
  this.m_wardrobeSystemExtra = WardrobeSystemExtra.GetInstance(this.m_player.GetGame());
  this.m_currentSetExtra = new ClothingSetExtra();
}

@replaceMethod(WardrobeSetEditorUIController)
private final func PopulateArea(targetRoot: wref<inkCompoundWidget>, container: ref<EquipmentAreaDisplays>, numberOfSlots: Int32, equipmentAreas: array<gamedataEquipmentArea>) -> Void {
  let availableItems: array<InventoryItemData>;
  let currentEquipmentArea: gamedataEquipmentArea;
  let i: Int32;
  let itemCount: Int32;
  let slot: wref<InventoryItemDisplayController>;
  let data: InventoryItemData;
  while ArraySize(container.displayControllers) > numberOfSlots {
    slot = ArrayPop(container.displayControllers);
    targetRoot.RemoveChild(slot.GetRootWidget());
  };
  while ArraySize(container.displayControllers) < numberOfSlots {
    slot = ItemDisplayUtils.SpawnCommonSlotController(this, targetRoot, n"visualDisplay") as InventoryItemDisplayController;
    ArrayPush(container.displayControllers, slot);
  };
  i = 0;
  while i < numberOfSlots {
    currentEquipmentArea = gamedataEquipmentArea.Invalid;
    if IsDefined(container.displayControllers[i]) {
      currentEquipmentArea = equipmentAreas[0];
      availableItems = this.m_wardrobeSystemExtra.GetFilteredInventoryItemsData(currentEquipmentArea, this.m_InventoryManager);
      itemCount = ArraySize(availableItems);
      container.displayControllers[i].BindVisualSlot(currentEquipmentArea, itemCount, data, i, ItemDisplayContext.GearPanel);
      ArrayPush(this.m_areaSlotControllers, container.displayControllers[i]);
    };
    i += 1;
  };
}

@addField(UIScriptableSystemWardrobeSetAdded)
public let wardrobeSetExtra: gameWardrobeClothingSetIndexExtra;

@replaceMethod(WardrobeSetEditorUIController)
public final func SaveSet() -> Void {
  let displayData: InventoryItemDisplayData;
  let i: Int32;
  let slotInfo: SSlotVisualInfo;
  let wardrobeSetAddedEvent: ref<UIScriptableSystemWardrobeSetAdded>;
  ArrayClear(this.m_currentSetExtra.clothingList);
  i = 0;
  while i < ArraySize(this.m_areaSlotControllers) {
    if ArrayContains(this.m_hiddenEquipmentAreas, this.m_areaSlotControllers[i].GetEquipmentArea()) {
      this.UpdateEquipementSlot(this.m_areaSlotControllers[i], this.m_areaSlotControllers[i].GetEquipmentArea());
      this.SetAreaSlotCovered(this.m_areaSlotControllers[i], true);
    };
    displayData = this.m_areaSlotControllers[i].GetItemDisplayData();
    slotInfo.areaType = displayData.m_equipmentArea;
    slotInfo.visualItem = this.m_wardrobeSystemExtra.GetStoredItemID(ItemID.GetTDBID(displayData.m_itemID));
    ArrayPush(this.m_currentSetExtra.clothingList, slotInfo);
    i += 1;
  };
  if ArraySize(this.m_currentSetExtra.clothingList) > 0 {
    this.m_wardrobeSystemExtra.PushBackClothingSet(this.m_currentSetExtra);
  };
  this.m_setButtonController.SetClothingSetChanged(false);
  if !this.m_setButtonController.GetDefined() {
    wardrobeSetAddedEvent = new UIScriptableSystemWardrobeSetAdded();
    wardrobeSetAddedEvent.wardrobeSetExtra = this.m_currentSetExtra.setID;
    this.m_uiScriptableSystem.QueueRequest(wardrobeSetAddedEvent);
  };
  this.m_setButtonController.SetDefined(true);
}

@replaceMethod(WardrobeSetEditorUIController)
protected cb func OnEquipmentkHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
  let itemTooltipData: ref<ATooltipData>;
  let slotName: String;
  let slotHidden: Bool = ArrayContains(this.m_hiddenEquipmentAreas, evt.display.GetEquipmentArea());
  if !slotHidden && !InventoryItemData.IsEmpty(evt.itemData) {
    itemTooltipData = this.m_InventoryManager.GetTooltipDataForVisualItem(evt.itemData, InventoryItemData.IsEquipped(evt.itemData));
    this.m_tooltipsManager.ShowTooltipAtWidget(n"visualTooltip", evt.widget, itemTooltipData, gameuiETooltipPlacement.RightTop, true);
    WardrobeSystemExtra.SendWardrobeInspectItemRequest(this.m_player.GetGame(), InventoryItemData.GetID(evt.itemData));
  } else {
    slotName = GetLocalizedText(evt.display.GetSlotName());
    this.m_tooltipsManager.ShowTooltipAtWidget(0, evt.widget, this.m_InventoryManager.GetTooltipForEmptySlot(slotName), gameuiETooltipPlacement.RightTop, true);
  };
  if !slotHidden {
    this.SetButtonHintsHoverOver(evt.display);
  };
}

@addMethod(WardrobeSetEditorUIController)
protected cb func OnEquipmentHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
  let itemTooltipData: ref<ATooltipData>;
  let slotName: String;
  let slotHidden: Bool = ArrayContains(this.m_hiddenEquipmentAreas, evt.display.GetEquipmentArea());
  if !slotHidden && !InventoryItemData.IsEmpty(evt.itemData) {
    itemTooltipData = this.m_InventoryManager.GetTooltipDataForVisualItem(evt.itemData, InventoryItemData.IsEquipped(evt.itemData));
    this.m_tooltipsManager.ShowTooltipAtWidget(n"visualTooltip", evt.widget, itemTooltipData, gameuiETooltipPlacement.RightTop, true);
    WardrobeSystemExtra.SendWardrobeInspectItemRequest(this.m_player.GetGame(), InventoryItemData.GetID(evt.itemData));
  } else {
    slotName = GetLocalizedText(evt.display.GetSlotName());
    this.m_tooltipsManager.ShowTooltipAtWidget(0, evt.widget, this.m_InventoryManager.GetTooltipForEmptySlot(slotName), gameuiETooltipPlacement.RightTop, true);
  };
  if !slotHidden {
    this.SetButtonHintsHoverOver(evt.display);
  };
}

@replaceMethod(WardrobeSetEditorUIController)
private final func UpdateEquipementSlot(itemDisplay: wref<InventoryItemDisplayController>, equipmentArea: gamedataEquipmentArea, opt inventoryItemData: InventoryItemData) -> Void {
  let availableItems: array<InventoryItemData>;
  let itemsCount: Int32;
  if InventoryItemData.IsEmpty(inventoryItemData) {
    availableItems = this.m_wardrobeSystemExtra.GetFilteredInventoryItemsData(equipmentArea, this.m_InventoryManager);
    itemsCount = ArraySize(availableItems);
  };
  itemDisplay.InvalidateVisualContent(inventoryItemData, itemsCount, !InventoryItemData.IsEmpty(inventoryItemData));
}

@replaceMethod(WardrobeSetEditorUIController)
private final func UpdateAvailableItems(equipmentArea: gamedataEquipmentArea) -> Void {
  let availableItemTDBID: TweakDBID;
  let availableItems: array<InventoryItemData>;
  let data: ref<WardrobeWrappedInventoryItemData>;
  let i: Int32;
  let itemRecord: wref<Item_Record>;
  let itemTDBIDInSlot: TweakDBID;
  let virtualWrappedData: array<ref<IScriptable>>;
  if Equals(equipmentArea, gamedataEquipmentArea.Invalid) {
    return;
  };
  availableItems = this.m_wardrobeSystemExtra.GetFilteredInventoryItemsData(equipmentArea, this.m_InventoryManager);
  itemTDBIDInSlot = ItemID.GetTDBID(this.GetItemInSlot(equipmentArea));
  inkWidgetRef.SetVisible(this.m_itemsGridWidget, true);
  i = 0;
  while i < ArraySize(availableItems) {
    availableItemTDBID = ItemID.GetTDBID(InventoryItemData.GetID(availableItems[i]));
    if itemTDBIDInSlot == availableItemTDBID {
    } else {
      data = new WardrobeWrappedInventoryItemData();
      data.ItemData = availableItems[i];
      data.ItemTemplate = 0u;
      data.ComparisonState = this.m_comparisonResolver.GetItemComparisonState(data.ItemData);
      data.IsNew = this.m_uiScriptableSystem.IsWardrobeItemNew(InventoryItemData.GetID(availableItems[i]));
      itemRecord = TweakDBInterface.GetItemRecord(availableItemTDBID);
      data.AppearanceName = NameToString(itemRecord.AppearanceName());
      InventoryItemData.SetGameItemData(data.ItemData, this.m_InventoryManager.GetPlayerItemData(InventoryItemData.GetID(availableItems[i])));
      ArrayPush(virtualWrappedData, data);
    };
    i += 1;
  };
  inkWidgetRef.SetVisible(this.m_emptyGridText, ArraySize(availableItems) <= 0);
  this.m_itemGridDataSource.Reset(virtualWrappedData);
}

@replaceMethod(WardrobeSetEditorUIController)
private final func SetAreaSlotCovered(slotConstroller: wref<InventoryItemDisplayController>, isCovered: Bool) -> Void {
  let availableItems: array<InventoryItemData>;
  let inventoryItemData: InventoryItemData;
  let itemsCount: Int32;
  let showEquipped: Bool;
  slotConstroller.SetWardrobeDisabled(isCovered);
  inventoryItemData = slotConstroller.GetItemData();
  if InventoryItemData.IsEmpty(inventoryItemData) && !isCovered {
    availableItems = this.m_wardrobeSystemExtra.GetFilteredInventoryItemsData(slotConstroller.GetEquipmentArea(), this.m_InventoryManager);
    itemsCount = ArraySize(availableItems);
  };
  showEquipped = !InventoryItemData.IsEmpty(inventoryItemData) && !isCovered;
  slotConstroller.InvalidateVisualContent(inventoryItemData, itemsCount, showEquipped);
  (slotConstroller as VisualDisplayController).SetIconsVisible(!isCovered);
}

@replaceMethod(WardrobeSetEditorUIController)
public final func OpenSet(setButtonController: wref<ClothingSetController>) -> Void {
  let callback: ref<WardrobeSetEditorUIDelayCallback> = new WardrobeSetEditorUIDelayCallback();
  callback.m_owner = this;
  this.m_setButtonController = setButtonController;
  this.m_currentSetExtra = setButtonController.GetClothingSetExtra();
  inkTextRef.SetText(this.m_itemGridText, " ");
  inkWidgetRef.SetVisible(this.m_itemsGridWidget, false);
  if IsDefined(this.m_delaySystem) {
    this.m_delaySystem.CancelCallback(this.m_delayedTimeoutCallbackId);
    this.m_delayedTimeoutCallbackId = this.m_delaySystem.DelayCallback(callback, this.m_timeoutPeroid, false);
  };
}

@replaceMethod(WardrobeSetEditorUIController)
public final func EquipCurrentSetVisuals() -> Void {
  this.EquipSetVisualsExtra(this.m_currentSetExtra);
  this.m_setButtonController.SetClothingSetChanged(false);
  this.UpdateButtonVisibility();
  this.SetAreaSlotHighlights(gamedataEquipmentArea.Invalid);
}

@addMethod(WardrobeSetEditorUIController)
protected final func EquipSetVisualsExtra(set: ref<ClothingSetExtra>) -> Void {
  let itemEquipped: Bool;
  let itemInventoryData: InventoryItemData;
  let j: Int32;
  let i: Int32 = 0;
  while i < ArraySize(this.m_areaSlotControllers) {
    itemEquipped = false;
    j = 0;
    while j < ArraySize(set.clothingList) {
      if Equals(this.m_areaSlotControllers[i].GetEquipmentArea(), set.clothingList[j].areaType) {
        itemInventoryData = this.m_InventoryManager.GetInventoryItemDataFromItemID(set.clothingList[j].visualItem);
        if ItemID.IsValid(InventoryItemData.GetID(itemInventoryData)) {
          this.EquipItem(this.m_areaSlotControllers[i].GetEquipmentArea(), itemInventoryData);
          itemEquipped = true;
        };
        break;
      };
      j += 1;
    };
    if !itemEquipped {
      this.UnequipItem(this.m_areaSlotControllers[i].GetEquipmentArea());
    };
    i += 1;
  };
}

@addField(EquipWardrobeSetRequest)
public let setIDExtra: gameWardrobeClothingSetIndexExtra;

@replaceMethod(WardrobeSetEditorUIController)
public final func SendVisualEquipRequest() -> Void {
  let request: ref<EquipWardrobeSetRequest> = new EquipWardrobeSetRequest();
  request.owner = this.m_player;
  request.setIDExtra = this.m_currentSetExtra.setID;
  this.m_equipmentSystem.QueueRequest(request);
}

@replaceMethod(WardrobeSetEditorUIController)
protected cb func OnTakeOffButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
  if evt.IsAction(n"click") {
    if this.m_setButtonController != null {
      this.SaveSet();
      this.m_wardrobeGameController.SetEquippedStateExtra(gameWardrobeClothingSetIndexExtra.INVALID);
      this.UpdateButtonVisibility();
    };
  };
}

@replaceMethod(WardrobeSetEditorUIController)
protected cb func OnWearButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
  if evt.IsAction(n"click") {
    if this.m_setButtonController != null {
      this.SaveSet();
      this.m_wardrobeGameController.SetEquippedStateExtra(this.m_setButtonController.GetClothingSetExtra().setID);
      this.UpdateButtonVisibility();
    };
  };
}

@replaceMethod(WardrobeSetEditorUIController)
protected cb func OnResetButtonClicked(evt: ref<inkPointerEvent>) -> Bool {
  if evt.IsAction(n"click") {
    if this.m_setButtonController != null {
      this.m_wardrobeGameController.ResetSetExtra(this.m_setButtonController.GetClothingSetExtra().setID);
      this.OpenSet(this.m_setButtonController);
      this.UpdateButtonVisibility();
    };
  };
}
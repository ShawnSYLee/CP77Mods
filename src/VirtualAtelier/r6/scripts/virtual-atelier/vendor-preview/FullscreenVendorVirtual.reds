import VendorPreview.ItemPreviewManager.VirtualAtelierPreviewManager
import VendorPreview.Utils.AtelierUtils
import VendorPreview.Utils.AtelierDebug

@addMethod(FullscreenVendorGameController)
private func BuyItemFromVirtualVendor(inventoryItemData: InventoryItemData) {
  let itemID: ItemID = InventoryItemData.GetID(inventoryItemData);
  // let tweakDBID: TweakDBID = ItemID.GetTDBID(itemID);
  let price = InventoryItemData.GetPrice(inventoryItemData);
  let quantity: Int32 = InventoryItemData.GetQuantity(inventoryItemData);
  let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_player.GetGame());
  let playerMoney: Int32 = this.m_VendorDataManager.GetLocalPlayerCurrencyAmount();
  let vendorNotification: ref<UIMenuNotificationEvent>;

  if playerMoney < Cast(price) {
    vendorNotification = new UIMenuNotificationEvent();
    vendorNotification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;
    GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(vendorNotification);
  } else {
    transactionSystem.GiveItem(this.m_player, itemID, quantity);
    transactionSystem.RemoveItemByTDBID(this.m_player, t"Items.money", Cast(price));
    // Refresh stock to regenerate ItemIDs
    this.PopulateVendorInventory();
  }
}

@addMethod(FullscreenVendorGameController)
private final func ShowTooltipsForItemController(targetWidget: wref<inkWidget>, equippedItem: InventoryItemData, inspectedItemData: InventoryItemData, iconErrorInfo: ref<DEBUG_IconErrorInfo>, isBuybackStack: Bool) -> Void {
  if this.GetIsVirtual() {
    let data: ref<InventoryTooltipData>;
    data = this.m_InventoryManager.GetTooltipDataForInventoryItem(inspectedItemData, InventoryItemData.IsEquipped(inspectedItemData), iconErrorInfo, InventoryItemData.IsVendorItem(inspectedItemData));
    data.displayContext = InventoryTooltipDisplayContext.Vendor;
    data.isVirtualItem = true;
    data.virtualInventoryItemData = inspectedItemData;
    this.m_TooltipsManager.ShowTooltipAtWidget(n"itemTooltip", targetWidget, data, gameuiETooltipPlacement.LeftTop);
  };
}


@wrapMethod(FullscreenVendorGameController)
protected cb func OnVendorFilterChange(controller: wref<inkRadioGroupController>, selectedIndex: Int32) -> Bool {
  wrappedMethod(controller, selectedIndex);
  
  if this.GetIsVirtual() {
    this.PopulateVendorInventory();
  };
}


// POPULATE VIRTUAL STOCK & SCALE

@addMethod(FullscreenVendorGameController)
private final func FillVirtualStock() -> Void {
  let inventoryManager: ref<InventoryManager> = GameInstance.GetInventoryManager(this.m_player.GetGame());
  let storeItems: array<String> = this.GetVirtualStoreItems();
  let itemsPrices: array<Int32> = this.GetVirtualStorePrices();
  let itemsQualities: array<CName> = this.GetVirtualStoreQualities();
  let itemsQuantities: array<Int32> = this.GetVirtualStoreQuantities();
  let vendorObject: ref<GameObject> = this.m_VendorDataManager.GetVendorInstance(); 

  let stockItem: ref<VirtualStockItem>;
  let virtualItemIndex = 0;
  ArrayClear(this.m_virtualStock);
  while virtualItemIndex < ArraySize(storeItems) {
    let itemTDBID: TweakDBID = TDBID.Create(storeItems[virtualItemIndex]);
    let itemId = ItemID.FromTDBID(itemTDBID);
    let itemData: ref<gameItemData> = inventoryManager.CreateBasicItemData(itemId, this.m_player);
    AtelierDebug(s"Store item: \(ToString(storeItems[virtualItemIndex]))");
    itemData.isVirtualItem = true;
    stockItem = new VirtualStockItem();
    stockItem.itemID = itemId;
    stockItem.itemTDBID = itemTDBID;
    stockItem.price = Cast<Float>(itemsPrices[virtualItemIndex]);
    stockItem.quality = itemsQualities[virtualItemIndex];
    stockItem.quantity = itemsQuantities[virtualItemIndex];
    AtelierDebug(s"   Dynamic tags: \(ToString(itemData.GetDynamicTags()))");
    AtelierDebug(s"   VirtPrice: \(ToString(stockItem.price))");
    if (RoundF(stockItem.price) == 0) {
      stockItem.price = Cast<Float>(AtelierUtils.ScaleItemPrice(this.m_player, vendorObject, itemId, stockItem.quality) * stockItem.quantity);
     };
    AtelierDebug(s"   CalcPrice: \(ToString(stockItem.price))");
    stockItem.itemData = itemData;
    ArrayPush(this.m_virtualStock, stockItem);
    virtualItemIndex += 1;
  };

  this.ScaleStockItems();
}

@addMethod(FullscreenVendorGameController)
private final func ScaleStockItems() -> Void {
  let itemData: wref<gameItemData>;
  let itemRecord: wref<Item_Record>;
  let i: Int32 = 0;
  while i < ArraySize(this.m_virtualStock) {
    itemRecord = TweakDBInterface.GetItemRecord(this.m_virtualStock[i].itemTDBID);
    if !itemRecord.IsSingleInstance() && !itemData.HasTag(n"Cyberware") {
      AtelierUtils.ScaleItem(this.m_player, this.m_virtualStock[i].itemData, this.m_virtualStock[i].quality);
    };
    i += 1;
  };
}

@addMethod(FullscreenVendorGameController)
private final func ConvertGameDataIntoInventoryData(data: array<ref<VirtualStockItem>>, owner: wref<GameObject>) -> array<InventoryItemData> {
  let itemData: InventoryItemData;
  let itemDataArray: array<InventoryItemData>;
  let stockItem: ref<VirtualStockItem>;
  let i: Int32 = 0;
  while i < ArraySize(data) {
    stockItem = data[i];
    itemData = this.m_InventoryManager.GetInventoryItemData(owner, stockItem.itemData);
    InventoryItemData.SetIsVendorItem(itemData, true);
    InventoryItemData.SetPrice(itemData, stockItem.price);
    InventoryItemData.SetBuyPrice(itemData, stockItem.price);
    InventoryItemData.SetQuantity(itemData, stockItem.quantity);
    InventoryItemData.SetQuality(itemData, stockItem.quality);
    ArrayPush(itemDataArray, itemData);
    i += 1;
  };
  return itemDataArray;
}

@wrapMethod(FullscreenVendorGameController)
private final func PopulateVendorInventory() -> Void {
  if this.GetIsVirtual() {
    this.PopulateVirtualShop();
  } else {
    wrappedMethod();
  };
}

@addMethod(FullscreenVendorGameController)
private func PopulateVirtualShop() -> Void {
let i: Int32;
    let items: array<ref<IScriptable>>;
    let playerMoney: Int32;
    let vendorInventory: array<InventoryItemData>;
    let vendorInventoryData: ref<VendorInventoryItemData>;
    let vendorInventorySize: Int32;
    this.m_vendorFilterManager.Clear();
    this.m_vendorFilterManager.AddFilter(ItemFilterCategory.AllItems);
    this.FillVirtualStock();
    vendorInventory = this.ConvertGameDataIntoInventoryData(this.m_virtualStock, this.m_VendorDataManager.GetVendorInstance());
    vendorInventorySize = ArraySize(vendorInventory);
    playerMoney = this.m_VendorDataManager.GetLocalPlayerCurrencyAmount();

    AtelierDebug(s"Resulting list size: \(vendorInventorySize)");

    i = 0;
    while i < vendorInventorySize {
      vendorInventoryData = new VendorInventoryItemData();
      vendorInventoryData.ItemData = vendorInventory[i];

      // Darkcopse requirements displaying fix
      if InventoryItemData.GetGameItemData(vendorInventoryData.ItemData).HasTag(n"Cyberware") {
        InventoryItemData.SetEquipRequirements(vendorInventoryData.ItemData, RPGManager.GetEquipRequirements(this.m_player, InventoryItemData.GetGameItemData(vendorInventoryData.ItemData)));
      };
      InventoryItemData.SetIsEquippable(vendorInventoryData.ItemData, EquipmentSystem.GetInstance(this.m_player).GetPlayerData(this.m_player).IsEquippable(InventoryItemData.GetGameItemData(vendorInventoryData.ItemData)));

      vendorInventoryData.IsVendorItem = true;
      vendorInventoryData.IsEnoughMoney = playerMoney >= Cast<Int32>(InventoryItemData.GetBuyPrice(vendorInventory[i]));
      vendorInventoryData.IsDLCAddedActiveItem = this.m_uiScriptableSystem.IsDLCAddedActiveItem(ItemID.GetTDBID(InventoryItemData.GetID(vendorInventory[i])));

      this.m_InventoryManager.GetOrCreateInventoryItemSortData(vendorInventoryData.ItemData, this.m_uiScriptableSystem);      
      this.m_vendorFilterManager.AddItem(vendorInventoryData.ItemData.GameItemData);
      ArrayPush(items, vendorInventoryData);
      i += 1;
    };

    this.m_vendorDataSource.Reset(items);
    this.m_vendorFilterManager.SortFiltersList();
    this.m_vendorFilterManager.InsertFilter(0, ItemFilterCategory.AllItems);
    this.SetFilters(this.m_vendorFiltersContainer, this.m_vendorFilterManager.GetIntFiltersList(), n"OnVendorFilterChange");
    this.m_vendorItemsDataView.EnableSorting();
    this.m_vendorItemsDataView.SetFilterType(this.m_lastVendorFilter);
    this.m_vendorItemsDataView.SetSortMode(this.m_vendorItemsDataView.GetSortMode());
    this.m_vendorItemsDataView.DisableSorting();
    this.ToggleFilter(this.m_vendorFiltersContainer, EnumInt(this.m_lastVendorFilter));
    inkWidgetRef.SetVisible(this.m_vendorFiltersContainer, ArraySize(items) > 0);
    this.PlayLibraryAnimation(n"vendor_grid_show");
}

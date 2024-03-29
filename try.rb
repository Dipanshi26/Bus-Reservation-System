<p style="color: green"><%= notice %></p>

<h1>Buses</h1>

<div id="buses">
  <% @buses.each do |bus| %>
    <%#=  render bus %>
    <p>
      <%= link_to bus.title, bus %>
    </p>
  <% end %>
</div>

<%= link_to "New bus", new_bus_path %>


<div class="seat-grid">
  <% @bus_seats.each do |seat| %>
    <% reserved_class = @reservation_seats.include?(seat.id) ? "reserved" : "available" %>
    <%= check_box_tag "seat_#{seat.seat_no}", 1, false, class: "seat-checkbox #{reserved_class}" %>
    <%= label_tag "seat_#{seat.seat_no}", "Seat #{seat.seat_no}", class: "seat-label" %>
  <% end %>
</div>
<%= form_tag(model: @bus, url: new_bus_reservation_path(@bus), method: 'post') do %>
  <% @bus_seats.each do |seat| %>
    <td><%= seat.seat_no %></td>
    <%= check_box_tag "seat_ids[]", seat.id, @reservation_seats.include?(seat.id) %>
  <% end %>


  # <table>
  #   <thead>
  #     <tr>
  #       <th>Seat Number</th>
  #       <th>Reserved</th>
  #     </tr>
  #   </thead>
  #   <tbody>
  #     <% @bus_seats.each do |seat| %>
  #       <tr>
  #         <td><%= seat.seat_no %></td>
  #         <td>
  #           <%= check_box_tag "seat_ids[]", seat.id, @reservation_seats.include?(seat.id) %>
  #         </td>
  #       </tr>
  #     <% end %>
  #   </tbody>
  # </table>
  <%= submit_tag "Submit" %>
<% end %>
























def create
  
  reservation_date = reservation_params[:reservation_date]
  puts reservation_date
  puts "jo"
  selected_seats = reservation_params[:seat_ids].map(&:to_i)
  puts selected_seats
  @bus_reserved_ids = @bus.reservations.where(reservation_date: reservation_date).pluck(:seat_id)
  
  if selected_seats.blank?
    flash[:alert] = 'Please select at least one seat.'
    redirect_back(fallback_location: root_path)
    return
  end
  # it is creating array of hashes (attributes)
  reservations_attributes = selected_seats.map do |seat_id|
    if @bus_reserved_ids.include?(seat_id)
      flash[:alert] = "You can't book an already booked seat."
      redirect_to action: :new
      return
    else
      {
        user_id: current_user.id,
        bus_id: reservation_params[:bus_id],
        seat_id: seat_id,
        reservation_date: reservation_date
      }
    end
  end

  Reservation.transaction do
    reservations = @bus.reservations.create(reservations_attributes)
    # it is creating all reservation at once
    if reservations.all?(&:persisted?)
      redirect_to @bus, notice: 'Reservations were successfully created.'
    else
      flash[:alert] = 'Some reservations were not created.'
      redirect_to action: :new
      raise ActiveRecord::Rollback # Rollback the transaction
    end
  end
end




<%= form_with(model: @reservation, url: bus_reservations_path(@bus), method: :post) do |form| %>
  <%= form.hidden_field :reservation_date, value: params[:reservation_date] %>
  <div class="container">
    <div class="seat-grid-container">
      <% @bus_seats.each do |seat| %>
        <% reserved_class = @reservation_seats.include?(seat.id) ? "reserved" : "available" %>
        <div class="seat <%= reserved_class %>">
          <% options = { multiple: true } %>
          <% options[:disabled] = true if @reservation_seats.include?(seat.id) %>
          <%= check_box_tag "reservation[seat_ids][]", seat.id, @reservation_seats.include?(seat.id), options %>
          <label for="seat_ids_<%= seat.id %>"><%= seat.seat_no %></label>
        </div>
      <% end %>
    </div>
    <div class="submit_tag">
      <%= submit_tag "Submit" %>
    </div>
  </div>
<% end %>


<%= form_with(model: @reservation, url: bus_reservations_path(@bus), method: :post) do |form| %>
  <div class="container">
    <div class="seat-grid-container">
      <% @bus_seats.each do |seat| %>
        <% reserved_class = @reservation_seat_ids.include?(seat.id) ? "reserved" : "available" %>
        <div class="seat <%= reserved_class %>">
          <% options = { multiple: true } %>
          <% options[:disabled] = true if @reservation_seat_ids.include?(seat.id) %>
          <%= check_box_tag "reservation[seat_ids][]", seat.id, @reservation_seat_ids.include?(seat.id), options %>
          <label for="reservation_seat_ids_<%= seat.id %>"><%= seat.seat_no %></label>
        </div>
      <% end %>
    </div>

    <%= form.hidden_field :reservation_date, value: params[:reservation_date] %>

    <div class="submit_tag">
      <%= submit_tag "Submit" %>
    </div>
  </div>
<% end %>


def create
  reservation_date = params[:bus][:reservation_date]
  selected_seats = params[:seat_ids]
  @bus_reserved_id = @bus.reservations.where(reservation_date: reservation_date).pluck(:seat_id)
  
  if selected_seats.blank?
    flash[:alert] = 'Please select at least one seat.'
    redirect_back(fallback_location: root_path)
    return
  end
  check = true
  
  selected_seats.each do |seat_id|
    if @bus_reserved_id.include?(seat_id.to_i)
      flash[:alert] = "You can't book an already booked seat."
      redirect_back(fallback_location: root_path)
      return
    else
      @reservation = @bus.reservations.build(user_id: current_user.id, bus_id: params[:bus_id], seat_id: seat_id, reservation_date: reservation_date)
      check &&= @reservation.save
      unless check 
        flash[:alert] = 'Reservation is not created'
        redirect_to action: :new
        return
      end
    end
  end
  
  if check
    redirect_to @bus, notice: 'Reservation was successfully created.'
    return 
  end
end



# scope module: 'owner' do
#   resources :buses, only: [] do
#     resources :reservations, only: [:index]
#   end
# end
# scope module: 'owner' do
#   resources :buses, except: %i[show]
#   resources :my_buses, only: [:index]
# end

# scope module: 'owner' do
#   resources :buses do
#     collection do
#       get 'search_bus'
#     end
#     member do
#       get 'reservation_date'
#       get 'available_seats'
#     end
#   end
# end
# resources :buses do
#   member do
#     get 'reservation_date', to: 'buses#reservation_date'
#     get 'available_seats', to: 'buses#available_seats'
#   end
# end
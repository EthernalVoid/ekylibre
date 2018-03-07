class InterventionParameterDecorator < Draper::Decorator
  delegate_all

  def input?
    object.is_a?(InterventionInput)
  end

  def real_cost
    return nil if object.product.nil?

    costs_params = { intervention_id: object.intervention_id,
                     product_id: object.product_id,
                     quantity: object.quantity_population,
                     unit_name: object.quantity_indicator_name,
                     intervention_started_at: object.intervention.started_at,
                     intervention_stopped_at: object.intervention.stopped_at }

    cost = ::Interventions::ParameterAmountInteractor
             .call(costs_params)

    return nil if cost.amount_computation.nil?

    cost.human_amount
  end
end
